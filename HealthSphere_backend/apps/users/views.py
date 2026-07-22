from rest_framework import status, generics
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from .models import Doctor, User
from .serializers import RegisterSerializer, LoginSerializer, DoctorSerializer

class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response({
                'message': 'User registered successfully.',
                'user': {
                    'id': user.id,
                    'email': user.email,
                    'full_name': user.full_name,
                    'role': user.role,
                }
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class DoctorListView(generics.ListAPIView):
    queryset = Doctor.objects.all()
    serializer_class = DoctorSerializer
    permission_classes = [AllowAny]

class DoctorProfileView(APIView):
    def get(self, request):
        email = request.query_params.get('email')
        try:
            doctor = Doctor.objects.get(user__email=email)
            serializer = DoctorSerializer(doctor)
            return Response(serializer.data)
        except Doctor.DoesNotExist:
            return Response({'error': 'Profile not found'}, status=status.HTTP_404_NOT_FOUND)

    def post(self, request):
        email = request.data.get('email')
        try:
            user = User.objects.get(email=email)
            doctor, created = Doctor.objects.get_or_create(user=user)

            # Handle multi-part/form-data for file uploads
            serializer = DoctorSerializer(doctor, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save(name=user.full_name)

                # Update status to pending if any document is present
                if doctor.medical_license or 'medical_license' in request.FILES:
                    if doctor.verification_status == 'unverified':
                        doctor.verification_status = 'pending'
                        doctor.save()

                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            user = serializer.validated_data['user']
            # Returning user details for now
            return Response({
                'message': 'Login successful.',
                'user': {
                    'id': user.id,
                    'email': user.email,
                    'full_name': user.full_name,
                    'role': user.role,
                }
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
