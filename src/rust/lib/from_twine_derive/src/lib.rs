use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, Data, DeriveInput, Fields, GenericParam, Lifetime};

/// Derive macro for `FromTwine<'a>` trait.
///
/// For structs: decodes as a twine array, one element per field (in definition order).
/// For enums: decodes as a twine constructor, matching variant index to definition order.
///
/// PhantomData fields are skipped (they don't consume an array slot).
#[proc_macro_derive(FromTwine)]
pub fn derive_from_twine(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    match derive_impl(input) {
        Ok(ts) => ts.into(),
        Err(e) => e.to_compile_error().into(),
    }
}

fn derive_impl(input: DeriveInput) -> syn::Result<proc_macro2::TokenStream> {
    let name = &input.ident;

    // Check if the type already has a lifetime 'a
    let has_lifetime_a = input
        .generics
        .lifetimes()
        .any(|lt| lt.lifetime.ident == "a");

    // Build the impl generics:
    // - If type has 'a, use it directly and add FromTwine<'a> bounds on type params
    // - If type has no 'a (immediate), introduce 'a for the impl
    let body = match &input.data {
        Data::Struct(data) => gen_struct(name, data)?,
        Data::Enum(data) => gen_enum(name, data)?,
        Data::Union(_) => {
            return Err(syn::Error::new_spanned(
                name,
                "FromTwine cannot be derived for unions",
            ))
        }
    };

    let (impl_generics, ty_generics, where_clause) = input.generics.split_for_impl();

    if has_lifetime_a {
        // Type already has 'a — add FromTwine<'a> bounds on type params
        let extra_bounds: Vec<_> = input
            .generics
            .params
            .iter()
            .filter_map(|p| match p {
                GenericParam::Type(tp) => {
                    let ident = &tp.ident;
                    Some(quote! { #ident: crate::deser::FromTwine<'a> })
                }
                _ => None,
            })
            .collect();

        let where_clause = if extra_bounds.is_empty() {
            quote! { #where_clause }
        } else {
            match where_clause {
                Some(wc) => quote! { #wc #(, #extra_bounds)* },
                None => quote! { where #(#extra_bounds),* },
            }
        };

        Ok(quote! {
            impl #impl_generics crate::deser::FromTwine<'a> for #name #ty_generics #where_clause {
                fn read(
                    d: &'_ twine_data::Decoder<'a>,
                    bump: &'a bumpalo::Bump,
                    off: twine_data::types::Offset,
                ) -> anyhow::Result<Self> {
                    #body
                }
            }
        })
    } else {
        // No lifetime — introduce 'a for the impl only
        // Collect existing type params to add FromTwine<'a> bounds
        let type_params: Vec<_> = input
            .generics
            .params
            .iter()
            .filter_map(|p| match p {
                GenericParam::Type(tp) => Some(&tp.ident),
                _ => None,
            })
            .collect();

        let lifetime_a: Lifetime = syn::parse_str("'a").unwrap();

        if type_params.is_empty() {
            // Simple immediate type, no generic params
            Ok(quote! {
                impl<#lifetime_a> crate::deser::FromTwine<#lifetime_a> for #name #ty_generics {
                    fn read(
                        d: &'_ twine_data::Decoder<#lifetime_a>,
                        bump: &#lifetime_a bumpalo::Bump,
                        off: twine_data::types::Offset,
                    ) -> anyhow::Result<Self> {
                        #body
                    }
                }
            })
        } else {
            // Has type params but no lifetime — add 'a and bounds
            let extra_bounds = type_params.iter().map(|ident| {
                quote! { #ident: crate::deser::FromTwine<#lifetime_a> }
            });
            let existing_where = where_clause.map(|wc| quote! { #wc, }).unwrap_or_default();

            Ok(quote! {
                impl<#lifetime_a, #(#type_params),*> crate::deser::FromTwine<#lifetime_a>
                    for #name<#(#type_params),*>
                    where #existing_where #(#extra_bounds),*
                {
                    fn read(
                        d: &'_ twine_data::Decoder<#lifetime_a>,
                        bump: &#lifetime_a bumpalo::Bump,
                        off: twine_data::types::Offset,
                    ) -> anyhow::Result<Self> {
                        #body
                    }
                }
            })
        }
    }
}

fn is_phantom_data(ty: &syn::Type) -> bool {
    if let syn::Type::Path(tp) = ty {
        tp.path
            .segments
            .last()
            .map_or(false, |seg| seg.ident == "PhantomData")
    } else {
        false
    }
}

fn gen_struct(_name: &syn::Ident, data: &syn::DataStruct) -> syn::Result<proc_macro2::TokenStream> {
    match &data.fields {
        Fields::Named(fields) => {
            // Filter out PhantomData fields for deserialization
            let real_fields: Vec<_> = fields
                .named
                .iter()
                .filter(|f| !is_phantom_data(&f.ty))
                .collect();
            let phantom_fields: Vec<_> = fields
                .named
                .iter()
                .filter(|f| is_phantom_data(&f.ty))
                .collect();

            let phantom_inits: Vec<_> = phantom_fields
                .iter()
                .map(|f| {
                    let fname = f.ident.as_ref().unwrap();
                    quote! { #fname: std::marker::PhantomData }
                })
                .collect();

            // Single-field structs are serialized as the field directly (transparent/newtype)
            if real_fields.len() == 1 {
                let fname = real_fields[0].ident.as_ref().unwrap();
                Ok(quote! {
                    Ok(Self {
                        #fname: crate::deser::FromTwine::read(d, bump, off)?,
                        #(#phantom_inits,)*
                    })
                })
            } else {
                let n = real_fields.len();
                let field_reads: Vec<_> = real_fields
                    .iter()
                    .enumerate()
                    .map(|(i, f)| {
                        let fname = f.ident.as_ref().unwrap();
                        quote! {
                            #fname: crate::deser::FromTwine::read(d, bump, offsets[#i])?
                        }
                    })
                    .collect();

                Ok(quote! {
                    let off = crate::deser::deref_tag(d, off)?;
                    let mut offsets = vec![];
                    d.get_array(off, &mut offsets)?;
                    anyhow::ensure!(
                        offsets.len() == #n,
                        "expected {} fields, got {}",
                        #n,
                        offsets.len()
                    );
                    Ok(Self {
                        #(#field_reads,)*
                        #(#phantom_inits,)*
                    })
                })
            }
        }
        Fields::Unnamed(fields) => {
            let n = fields.unnamed.len();

            // Single-field tuple structs are serialized as the field directly
            if n == 1 {
                Ok(quote! {
                    Ok(Self(crate::deser::FromTwine::read(d, bump, off)?))
                })
            } else {
                let field_reads: Vec<_> = (0..n)
                    .map(|i| {
                        quote! {
                            crate::deser::FromTwine::read(d, bump, offsets[#i])?
                        }
                    })
                    .collect();

                Ok(quote! {
                    let off = crate::deser::deref_tag(d, off)?;
                    let mut offsets = vec![];
                    d.get_array(off, &mut offsets)?;
                    anyhow::ensure!(
                        offsets.len() == #n,
                        "expected {} fields, got {}",
                        #n,
                        offsets.len()
                    );
                    Ok(Self(#(#field_reads),*))
                })
            }
        }
        Fields::Unit => Ok(quote! {
            d.get_null(off)?;
            Ok(Self)
        }),
    }
}

fn gen_enum(name: &syn::Ident, data: &syn::DataEnum) -> syn::Result<proc_macro2::TokenStream> {
    let arms: Vec<_> = data
        .variants
        .iter()
        .enumerate()
        .map(|(idx, variant)| {
            let vname = &variant.ident;
            let idx_u32 = idx as u32;

            match &variant.fields {
                Fields::Unit => {
                    // Nullary variant: no args expected
                    quote! {
                        #idx_u32 => {
                            Ok(Self::#vname)
                        }
                    }
                }
                Fields::Unnamed(fields) => {
                    let n = fields.unnamed.len();
                    let field_reads: Vec<_> = (0..n)
                        .map(|i| {
                            quote! {
                                crate::deser::FromTwine::read(d, bump, args[#i])?
                            }
                        })
                        .collect();

                    quote! {
                        #idx_u32 => {
                            anyhow::ensure!(
                                args.len() == #n,
                                "variant {} expected {} args, got {}",
                                stringify!(#vname),
                                #n,
                                args.len()
                            );
                            Ok(Self::#vname(#(#field_reads),*))
                        }
                    }
                }
                Fields::Named(fields) => {
                    // Filter out PhantomData for struct variants too
                    let real_fields: Vec<_> = fields
                        .named
                        .iter()
                        .filter(|f| !is_phantom_data(&f.ty))
                        .collect();
                    let phantom_fields: Vec<_> = fields
                        .named
                        .iter()
                        .filter(|f| is_phantom_data(&f.ty))
                        .collect();

                    let n = real_fields.len();
                    let field_reads: Vec<_> = real_fields
                        .iter()
                        .enumerate()
                        .map(|(i, f)| {
                            let fname = f.ident.as_ref().unwrap();
                            quote! {
                                #fname: crate::deser::FromTwine::read(d, bump, args[#i])?
                            }
                        })
                        .collect();

                    let phantom_inits: Vec<_> = phantom_fields
                        .iter()
                        .map(|f| {
                            let fname = f.ident.as_ref().unwrap();
                            quote! { #fname: std::marker::PhantomData }
                        })
                        .collect();

                    quote! {
                        #idx_u32 => {
                            anyhow::ensure!(
                                args.len() == #n,
                                "variant {} expected {} args, got {}",
                                stringify!(#vname),
                                #n,
                                args.len()
                            );
                            Ok(Self::#vname {
                                #(#field_reads,)*
                                #(#phantom_inits,)*
                            })
                        }
                    }
                }
            }
        })
        .collect();

    let name_str = name.to_string();

    Ok(quote! {
        let off = crate::deser::deref_tag(d, off)?;
        let mut args = vec![];
        let idx = d.get_variant(off, &mut args)?;
        match idx.0 {
            #(#arms)*
            other => anyhow::bail!(
                "{}: unknown constructor index {}",
                #name_str,
                other
            ),
        }
    })
}
