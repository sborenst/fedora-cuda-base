#!/usr/bin/env python3
"""
Test script to verify CUDA installation in the container
"""
import sys

def test_cuda_availability():
    """Test if CUDA is available and working"""
    print("=" * 50)
    print("CUDA Installation Test")
    print("=" * 50)
    
    try:
        import torch
        print(f"✅ PyTorch version: {torch.__version__}")
        
        # Check CUDA availability
        cuda_available = torch.cuda.is_available()
        print(f"✅ CUDA available: {cuda_available}")
        
        if cuda_available:
            device_count = torch.cuda.device_count()
            print(f"✅ CUDA device count: {device_count}")
            
            # Get CUDA version
            cuda_version = torch.version.cuda
            print(f"✅ CUDA version: {cuda_version}")
            
            # List all available devices
            for i in range(device_count):
                device_name = torch.cuda.get_device_name(i)
                print(f"✅ Device {i}: {device_name}")
                
                # Get device properties
                props = torch.cuda.get_device_properties(i)
                print(f"   - Memory: {props.total_memory / 1024**3:.1f} GB")
                print(f"   - Compute capability: {props.major}.{props.minor}")
            
            # Test basic CUDA operations
            print("\n" + "=" * 30)
            print("Testing CUDA Operations")
            print("=" * 30)
            
            # Create tensors on GPU
            device = torch.device('cuda:0')
            x = torch.randn(1000, 1000, device=device)
            y = torch.randn(1000, 1000, device=device)
            
            # Perform matrix multiplication
            z = torch.mm(x, y)
            print(f"✅ Matrix multiplication test passed")
            print(f"   Result tensor shape: {z.shape}")
            print(f"   Result tensor device: {z.device}")
            
            return True
        else:
            print("❌ CUDA is not available")
            return False
            
    except ImportError as e:
        print(f"❌ Failed to import PyTorch: {e}")
        return False
    except Exception as e:
        print(f"❌ CUDA test failed: {e}")
        return False

def test_cudnn():
    """Test cuDNN availability"""
    try:
        import torch
        if torch.cuda.is_available():
            cudnn_available = torch.backends.cudnn.enabled
            print(f"✅ cuDNN enabled: {cudnn_available}")
            if cudnn_available:
                print(f"✅ cuDNN version: {torch.backends.cudnn.version()}")
            return cudnn_available
        return False
    except Exception as e:
        print(f"❌ cuDNN test failed: {e}")
        return False

if __name__ == "__main__":
    print("Starting CUDA installation verification...\n")
    
    cuda_ok = test_cuda_availability()
    print()
    cudnn_ok = test_cudnn()
    
    print("\n" + "=" * 50)
    print("SUMMARY")
    print("=" * 50)
    
    if cuda_ok:
        print("✅ CUDA installation: PASSED")
    else:
        print("❌ CUDA installation: FAILED")
    
    if cudnn_ok:
        print("✅ cuDNN installation: PASSED")
    else:
        print("❌ cuDNN installation: FAILED")
    
    if cuda_ok and cudnn_ok:
        print("\n🎉 Container is ready for GPU-accelerated applications!")
        sys.exit(0)
    else:
        print("\n⚠️  Some issues detected. Check the output above.")
        sys.exit(1)