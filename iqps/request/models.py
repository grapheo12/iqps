from data.models import PAPER_TYPES
from django.db import models



class PaperRequest(models.Model):
    subject = models.CharField(max_length=2048)
    paper_type = models.CharField(max_length=2, choices=PAPER_TYPES)
    year = models.IntegerField()
    added_on = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'paper_requests'

    def __str__(self):
        return f"{self.subject}-{self.year}-{self.paper_type}"

    def __iter__(self):
        yield ("id", self.pk)
        yield ("subject", self.subject)
        yield ("paper_type", self.paper_type)
        yield ("year", self.year)
