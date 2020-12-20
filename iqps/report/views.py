from django.shortcuts import render, get_object_or_404
from django.contrib import messages
from .forms import ReportForm
from data.models import Paper
import os

def reportPaper(request, paperId):
    paper = get_object_or_404(Paper, pk=paperId)
    form = None
    try:
        assert request.method == "POST"
        form = ReportForm(request.POST)
        assert form.is_valid()
        report = form.save(commit=False)
        report.paper = paper
        report.save()
        messages.add_message(request, messages.INFO, "Report Successful!")
        return render(request, "reportform.html", {
            "form": ReportForm(),
            "paper": paper,
            "login_req": os.environ['LOGIN_REQUIRED']
        })
    except Exception:
        if form is None:
            form = ReportForm()
        return render(request, "reportform.html", {
            "form": form,
            "paper": paper,
            "login_req": os.environ['LOGIN_REQUIRED']
        })
