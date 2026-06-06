import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_model.dart';
import '../models/penjualan_model.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final PenjualanModel? order;
  final String userLevel; // 'admin' atau 'pelanggan'

  const ChatScreen({super.key, this.order, required this.userLevel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _api = ApiService();
  final _pesanCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<ChatModel> _messages = [];
  bool _isFirstLoad = true;
  bool _isSending = false;
  String _errorMessage = '';

  Timer? _pollingTimer;
  static const _pollingInterval = Duration(seconds: 3);

  bool get _isAdmin => widget.userLevel.toLowerCase() == 'admin';

  Color get _themeColor => _isAdmin ? Colors.indigo : Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ambilPesan();
    _startPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      _ambilPesan(silently: true);
    } else if (state == AppLifecycleState.paused) {
      _stopPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _ambilPesan(silently: true);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    _pesanCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _ambilPesan({bool silently = false}) async {
    try {
      final idPenjualan = widget.order?.idPenjualan ?? 0;
      final list = await _api.fetchChat(idPenjualan);

      if (!mounted) return;

      final int oldLength = _messages.length;

      setState(() {
        _messages = list;
        _isFirstLoad = false;
        _errorMessage = '';
      });

      // Scroll ke bawah hanya jika ada pesan baru
      if (list.length != oldLength || (_isFirstLoad && list.isNotEmpty)) {
        _lompatKeBawah();
      }
    } catch (e) {
      debugPrint("🔴 ERROR FETCH CHAT: $e");
      if (!mounted) return;

      if (!silently || _messages.isEmpty) {
        setState(() {
          _isFirstLoad = false;
          _errorMessage = 'Gagal memuat chat: ${e.toString().replaceFirst("Exception: ", "")}';
        });
      }
    }
  }

  void _lompatKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _kirimObrolan() async {
    final teks = _pesanCtrl.text.trim();
    if (teks.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    // Optimistic UI: tambahkan pesan langsung ke list
    final idPenjualan = widget.order?.idPenjualan ?? 0;
    final tempMsg = ChatModel(
      idChat: -1, // ID sementara
      idPenjualan: idPenjualan,
      pengirim: widget.userLevel.toLowerCase(),
      pesan: teks,
      tanggal: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );
    setState(() {
      _messages.add(tempMsg);
    });
    _pesanCtrl.clear();
    _lompatKeBawah();

    try {
      await _api.kirimPesan(idPenjualan, teks);
      // Refresh untuk sinkronkan ID chat yang benar dari server
      await _ambilPesan(silently: true);
    } catch (e) {
      if (!mounted) return;
      // Hapus pesan optimistic jika gagal kirim
      setState(() {
        _messages.removeWhere((m) => m.idChat == -1 && m.pesan == teks);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gagal kirim: ${e.toString().replaceFirst("Exception: ", "")}',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatWaktu(String tanggal) {
    try {
      final dt = DateTime.parse(tanggal);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(dt.year, dt.month, dt.day);

      if (msgDay == today) {
        return DateFormat('HH:mm').format(dt);
      } else if (msgDay == today.subtract(const Duration(days: 1))) {
        return 'Kemarin ${DateFormat('HH:mm').format(dt)}';
      } else {
        return DateFormat('d MMM, HH:mm').format(dt);
      }
    } catch (_) {
      return tanggal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              child: Icon(
                _isAdmin ? Icons.support_agent_rounded : Icons.store_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order != null
                        ? 'Chat Nota #SPN-${widget.order!.idPenjualan}'
                        : 'Pusat Bantuan',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _isAdmin ? 'Admin' : 'Pelanggan',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat ulang',
            onPressed: () => _ambilPesan(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner error
          if (_errorMessage.isNotEmpty)
            Material(
              color: Colors.red.shade50,
              child: InkWell(
                onTap: () => _ambilPesan(),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        'Coba lagi',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Area pesan
          Expanded(
            child: _isFirstLoad
                ? Center(
                    child: CircularProgressIndicator(color: _themeColor),
                  )
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final chat = _messages[index];
                          final bool isMe = chat.pengirim.toLowerCase() ==
                              widget.userLevel.toLowerCase();

                          // Apakah perlu menampilkan pemisah tanggal?
                          bool showDateSeparator = false;
                          if (index == 0) {
                            showDateSeparator = true;
                          } else {
                            final prev = _messages[index - 1];
                            try {
                              final prevDate =
                                  DateTime.parse(prev.tanggal);
                              final currDate =
                                  DateTime.parse(chat.tanggal);
                              if (prevDate.day != currDate.day ||
                                  prevDate.month != currDate.month) {
                                showDateSeparator = true;
                              }
                            } catch (_) {}
                          }

                          return Column(
                            children: [
                              if (showDateSeparator)
                                _buildDateSeparator(chat.tanggal),
                              _buildBubble(chat, isMe),
                            ],
                          );
                        },
                      ),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 40, color: _themeColor.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada obrolan',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Text(
            'Ketik pesan pertama Anda di bawah ini.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String tanggal) {
    String label = '';
    try {
      final dt = DateTime.parse(tanggal);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(dt.year, dt.month, dt.day);

      if (msgDay == today) {
        label = 'Hari ini';
      } else if (msgDay == today.subtract(const Duration(days: 1))) {
        label = 'Kemarin';
      } else {
        label = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dt);
      }
    } catch (_) {
      label = tanggal;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatModel chat, bool isMe) {
    final isTemp = chat.idChat == -1; // Pesan optimistic yang belum tersimpan

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 6,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Label pengirim (hanya untuk pesan lawan)
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 3),
                child: Text(
                  chat.pengirim == 'admin' ? '🛡️ Admin' : '👤 Pelanggan',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600),
                ),
              ),

            // Bubble pesan
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? _themeColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                chat.pesan,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
            ),

            // Timestamp + status
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatWaktu(chat.tanggal),
                    style:
                        TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      isTemp
                          ? Icons.access_time_rounded
                          : Icons.done_all_rounded,
                      size: 13,
                      color: isTemp ? Colors.grey : Colors.blue.shade400,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 16,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _pesanCtrl,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 14.5),
                  decoration: const InputDecoration(
                    hintText: 'Ketik pesan...',
                    hintStyle: TextStyle(fontSize: 14),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _kirimObrolan(),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Tombol kirim
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: _themeColor,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _isSending ? null : _kirimObrolan,
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
