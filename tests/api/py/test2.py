import imandrax_api.lib as xtypes

# run test1.py first to get artifacts

print(f'\n{"#"*80}\n')
art = xtypes.read_artifact_zip("art.po_task.zip")
print(f'artifact task: {art}')

print(f'\n{"#"*80}\n')
art = xtypes.read_artifact_zip("art.po_res.zip")
print(f'artifact res: {art}')

