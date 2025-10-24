from django.shortcuts import render, redirect
from .models import Login

def login_view(request):
    if request.method == "POST":
        username = request.POST.get("username").strip()
        password = request.POST.get("password").strip()
        try:
            user = Login.objects.get(username=username)
            if user.password == password:
                request.session['username'] = username
                return redirect('home')
            else:
                return render(request, 'login.html', {'error': 'Invalid credentials'})
        except Login.DoesNotExist:
            return render(request, 'login.html', {'error': 'Invalid credentials'})
    return render(request, 'login.html')

def register_view(request):
    if request.method == "POST":
        username = request.POST.get("username").strip()
        password = request.POST.get("password").strip()
        if username and password:
            if not Login.objects.filter(username=username).exists():
                Login.objects.create(username=username, password=password)
                return redirect('login')
            else:
                return render(request, 'register.html', {'error': 'User exists'})
        else:
            return render(request, 'register.html', {'error': 'Fill all fields'})
    return render(request, 'register.html')

def home_view(request):
    username = request.session.get('username')
    if not username:
        return redirect('login')
    return render(request, 'home.html', {'username': username})

def logout_view(request):
    try:
        del request.session['username']
    except KeyError:
        pass
    return redirect('login')
