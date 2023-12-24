#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <string>
#include <stdio.h>
#include <iostream>
#include <cstdlib>
#include <windows.h>

using namespace std;

__global__ void matrixMult(const int* A, const int* B, int* C, int matrix)
{
    int i = matrix * (blockDim.y * blockIdx.y + threadIdx.y);
    int j = blockDim.x * blockIdx.x + threadIdx.x;
    int sum = 0;

    for (int k = 0; k < matrix; k++)
        sum += A[i + k] * B[k * matrix + j];

    int ind = matrix * (blockDim.y * blockIdx.y + threadIdx.y) + blockDim.x * blockIdx.x + threadIdx.x;
    C[ind] = sum;
}

int main(int argc, char** argv) {

    SetConsoleOutputCP(CP_UTF8);

    int threads, matrix;
    bool flag_thread = true, flag_matrix = true;
    string thread_input, matrix_size;

    cout << "Enter the number of threads: " << endl;

    while (flag_thread == true)
    {
        try
        {
            cin >> thread_input;
            threads = stoi(thread_input);

            if (threads < 0) 
            {
                cin.clear();
                cin.ignore(cin.rdbuf()->in_avail());
                cout << "Incorrect data entry. Try entering again" << endl;
                cout << "Enter the number of threads: ";
            }
            else
                flag_thread = false;
        }
        catch (invalid_argument)
        {
            cin.clear();
            cin.ignore(cin.rdbuf()->in_avail());
            cout << "Incorrect data entry. Try entering again" << endl;
            cout << "Enter the number of threads: ";
        }
    }

    cout << "Enter matrix size = ";

    while (flag_matrix == true)
    {
        try
        {
            cin >> matrix_size;
            matrix = stoi(matrix_size);

            if (matrix < 0)
            {
                cin.clear();
                cin.ignore(cin.rdbuf()->in_avail());
                cout << "Incorrect data entry. Try entering again" << endl;
                cout << "Enter the number of threads: ";
            }
            else
                flag_matrix = false;
        }
        catch (invalid_argument)
        {
            cin.clear();
            cin.ignore(cin.rdbuf()->in_avail());
            cout << "Incorrect data entry. Try entering again" << endl;
            cout << "Enter the number of threads: ";
        }
    }

    size_t size = matrix * matrix * sizeof(int);

    int* a = (int*)malloc(size);
    int* b = (int*)malloc(size);
    int* c = (int*)malloc(size);

    for (int i = 0; i < matrix; i++) {
        for (int j = 0; j < matrix; j++) {
            a[i * matrix + j] = i * j;
            b[i * matrix + j] = i * j;
        }
    }

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int* calcA = NULL;
    cudaMalloc((void**)&calcA, size);

    int* calcB = NULL;
    cudaMalloc((void**)&calcB, size);

    int* calcC = NULL;
    cudaMalloc((void**)&calcC, size);

    cudaMemcpy(calcA, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(calcB, b, size, cudaMemcpyHostToDevice);

    cout << "Start programm" << endl;

    dim3 threadsPerBlock = dim3(threads, threads);
    dim3 blocksPerGrid = dim3(matrix / threads, matrix / threads);

    cudaEventRecord(start, 0);
    matrixMult <<< blocksPerGrid, threadsPerBlock >>> (calcA, calcB, calcC, matrix);

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float kernelTime;
    cudaEventElapsedTime(&kernelTime, start, stop);
    double time = kernelTime;
    cout << "Threads on block: " << threads
        << "; block in cell: " << matrix / threads
        << "; worktime: " << kernelTime / 1000 << " sec" << endl;
    cudaMemcpy(c, calcC, size, cudaMemcpyDeviceToHost);

    cudaFree(calcA);
    cudaFree(calcB);
    cudaFree(calcC);
    free(a);
    free(b);
    free(c);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
