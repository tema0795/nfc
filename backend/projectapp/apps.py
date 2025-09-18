from django.apps import AppConfig


class ProjectappConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "projectapp"

    def ready(self):
        from .scheduler import start_scheduler
        start_scheduler()
