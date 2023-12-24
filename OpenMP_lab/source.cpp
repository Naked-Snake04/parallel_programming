#include <iostream>
#include <string>
#include <omp.h>
#include <stdio.h>
#include <windows.h>

using namespace std;

int main() 
{
	int i, j, k;
	int value, matrix, max_value;
	double t1, t2;
	bool flag_thread = true, flag_matrix = true;
	string thread_input, matrix_size;

	//Узнаём количество потоков
	max_value = omp_get_max_threads();

	cout << "There are " << max_value << " threads available on your system"  << endl;
	cout << "Enter the number of threads: " << endl;

	//Вводим количество потоков
	while (flag_thread == true)
	{
		try
		{
			cin >> thread_input;
			value = stoi(thread_input);

			if (value < 0 || value > max_value) {
				cin.clear();
				cin.ignore(cin.rdbuf()->in_avail());
				cout << "Incorrect data entry. Try entering again" << endl;
				cout << "Enter the number of threads: ";
			}
			else
			{
				omp_set_num_threads(value);
				flag_thread = false;
			}

		}
		catch (invalid_argument)
		{
			cin.clear();
			cin.ignore(cin.rdbuf()->in_avail());
			cout << "Incorrect data entry. Try entering again" << endl;
			cout << "Enter the number of threads: ";
		}
	}

	// Вводим размер матрицы
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
				cout << "Enter matrix size = ";
			}
			else
				flag_matrix = false;
		}
		catch (invalid_argument)
		{
			cin.clear();
			cin.ignore(cin.rdbuf()->in_avail());
			cout << "Incorrect data entry. Try entering again" << endl;
			cout << "Enter matrix size = ";
		}
	}

	// Создаём матрицу
	int** a = new int* [matrix];
	for (int i = 0; i < matrix; i++)
		a[i] = new int[matrix];

	int** b = new int* [matrix];
	for (int i = 0; i < matrix; i++)
		b[i] = new int[matrix];

	int** c = new int* [matrix];
	for (int i = 0; i < matrix; i++)
		c[i] = new int[matrix];

	// заполнение матриц
	for (int i = 0; i < matrix; i++)
		for (int j = 0; j < matrix; j++)
			a[i][j] = b[i][j] = i * j;

	// Запускаем OpenMP
	cout << "Start time" << endl;
	t1 = omp_get_wtime(); // Время начала работы

	// основной вычислительный блок
	#pragma omp parallel for shared(a, b, c) private(i, j, k)
	// Перемножение матриц
	for (int i = 0; i < matrix; i++)
	{
		for (int j = 0; j < matrix; j++)
		{
			c[i][j] = 0;
			for (int k = 0; k < matrix; k++)
				c[i][j] += a[i][k] * b[k][j];
		}
	}

	t2 = omp_get_wtime(); // Время конца работы
	cout << "End time" << endl;

	for (int i = 0; i < matrix; i++)
		delete a[i], b[i], c[i];
	delete[] a, b, c;


	// Выводим общее время
	cout << "Worktime on " << value
		<< " threads for matrix with size " << matrix
		<< " is " << t2 - t1 << " seconds" << endl;

	return 0;
}