from data.models import Paper
from django.db import models


class Report(models.Model):
    paper = models.ForeignKey(Paper, on_delete=models.CASCADE)
    reason = models.CharField(max_length=1024)
