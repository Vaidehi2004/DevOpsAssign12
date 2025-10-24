from django.db import models

class Login(models.Model):
    username = models.CharField(max_length=64, primary_key=True)
    password = models.CharField(max_length=128)

    class Meta:
        db_table = 'login'
