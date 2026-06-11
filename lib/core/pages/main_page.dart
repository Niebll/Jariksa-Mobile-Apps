import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/core/widgets/app_navbar.dart';
import 'package:jariksa/features/home/view/home_page.dart';
import 'package:jariksa/features/order_list/view/order_list_page.dart';
import 'package:jariksa/features/order/cubit/customer_check_cubit.dart';
import 'package:jariksa/features/order/view/order_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Daftar halaman untuk setiap tab
  final List<Widget> _pages = [
    const HomePage(),
    const OrderListPage(),
    const _PlaceholderPage(label: 'Pelanggan'),
    const _PlaceholderPage(label: 'Toko'),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _onFabTapped() {
    context.read<CustomerCheckCubit>().reset();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OrderPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),

      // FAB di tengah notch
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabTapped,
        backgroundColor: ColorValue.primary600,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: AppNavbar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
        onFabTapped: _onFabTapped,
      ),
    );
  }
}

// Placeholder sementara untuk halaman yang belum dibuat
class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValue.primary50,
      body: Center(
        child: Text(
          'Halaman $label\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: ColorValue.neutral500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
