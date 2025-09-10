import os
import logging

import structlog
from structlog.stdlib import LoggerFactory, add_log_level


def configure(force = False):
    """
    Configures logging & structlog modules

    Keyword Arguments:
    force: Force to reconfigure logging.
    """

    if structlog.is_configured() and not force:
        return

    # Check whether debug flag is set
    debug = os.environ.get('DEBUG_MODE', False)
    # Set appropriate log level
    if debug:
        log_level = logging.DEBUG
    else:
        log_level = logging.INFO

    # Set logging config
    logging.basicConfig(
        level = log_level,
        format = "%(message)s",
    )

    # Configure structlog
    structlog.configure(
        logger_factory = LoggerFactory(),
        processors = [
            add_log_level,
            # Add timestamp
            structlog.processors.TimeStamper('iso'),
            # Add stack information
            structlog.processors.StackInfoRenderer(),
            # Set exception field using exec info
            structlog.processors.format_exc_info,
            # Render event_dict as JSON
            structlog.processors.JSONRenderer()
        ]
    )


def get_logger(**kwargs):
    """
    Get the structlog logger
    """
    # Configure logging modules
    configure()
    # Return structlog
    return structlog.get_logger(**kwargs)
