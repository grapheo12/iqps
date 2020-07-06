from django.contrib import admin

from .models import Department, Keyword, Paper



class PaperAdmin(admin.ModelAdmin):
    model = Paper
    filter_horizontal = ('keywords',)


admin.site.register(Paper, PaperAdmin)
admin.site.register(Keyword)
admin.site.register(Department)
