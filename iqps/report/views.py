from django.contrib import messages
from django.shortcuts import get_object_or_404, render

from data.models import Paper

from .forms import ReportForm



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
            "paper": paper
        })
    except Exception:
        if form is None:
            form = ReportForm()
        return render(request, "reportform.html", {
            "form": form,
            "paper": paper
        })
