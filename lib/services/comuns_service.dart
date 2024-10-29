import 'package:flutter/material.dart';

class ComunsService {

  List<DropdownMenuItem<String>> getEntradaOptions() {
    return const [
      DropdownMenuItem(value: 'Dízimo', child: Text('Dízimo')),
      DropdownMenuItem(value: 'Oferta', child: Text('Oferta')),
      DropdownMenuItem(value: 'Outros', child: Text('Outros')),
    ];
  }

  List<DropdownMenuItem<String>> getSaidaOptions() {
    return const [
      DropdownMenuItem(value: 'Compras', child: Text('Compras')),
      DropdownMenuItem(value: 'Despesas', child: Text('Despesas Gerais')),
      DropdownMenuItem(value: 'Outros', child: Text('Outros')),
    ];
  }

  List<DropdownMenuItem<String>> getEntradaPessoalOptions() {
    return const [
      DropdownMenuItem(value: 'Salário', child: Text('Salário')),
      DropdownMenuItem(value: 'Renda Extra', child: Text('Renda Extra')),
      DropdownMenuItem(value: 'Outros', child: Text('Outros')),
    ];
  }

  List<DropdownMenuItem<String>> getSaidaPessoalOptions() {
    return const [
      DropdownMenuItem(value: 'Compras', child: Text('Compras')),
      DropdownMenuItem(value: 'Gastos Fixo', child: Text('Gastos Fixo')),
      DropdownMenuItem(value: 'Outros', child: Text('Outros')),
    ];
  }

  List<DropdownMenuItem<String>> getPagamentoSaidaOptions() {
    return const [
      DropdownMenuItem(value: '', child: Text('Selecione uma opção')),
      DropdownMenuItem(value: 'Pago', child: Text('Pago')),
      DropdownMenuItem(value: 'Falta Pagar', child: Text('Falta Pagar')),
    ];
  }

  List<DropdownMenuItem<String>> getPagamentoEntradaOptions() {
    return const [
      DropdownMenuItem(value: '', child: Text('Selecione uma opção')),
      DropdownMenuItem(value: 'Recebido', child: Text('Recebido')),
      DropdownMenuItem(value: 'Falta Receber', child: Text('Falta Receber')),
    ];
  }

  List<DropdownMenuItem<String>> getPagamentoOptions() {
    return const [
      DropdownMenuItem(value: '', child: Text('Filtrar Todos')),
      DropdownMenuItem(value: 'Pago', child: Text('Pago')),
      DropdownMenuItem(value: 'Falta Pagar', child: Text('Falta Pagar')),
      DropdownMenuItem(value: 'Recebido', child: Text('Recebido')),
      DropdownMenuItem(value: 'Falta Receber', child: Text('Falta Receber')),
    ];
  }

  List<DropdownMenuItem<String>> getAnoOptions() {
    return const [
      DropdownMenuItem(value: '', child: Text('Todos os anos')),
      DropdownMenuItem(value: '2023', child: Text('2023')),
      DropdownMenuItem(value: '2024', child: Text('2024')),
      DropdownMenuItem(value: '2025', child: Text('2025')),
      DropdownMenuItem(value: '2026', child: Text('2026')),
    ];
  }

  List<DropdownMenuItem<String>> getMesOptions() {
    return const [
      DropdownMenuItem(value: '', child: Text('Todos os mêses')),
      DropdownMenuItem(value: '01', child: Text('Janeiro')),
      DropdownMenuItem(value: '02', child: Text('Fevereiro')),
      DropdownMenuItem(value: '03', child: Text('Março')),
      DropdownMenuItem(value: '04', child: Text('Abril')),
      DropdownMenuItem(value: '05', child: Text('Maio')),
      DropdownMenuItem(value: '06', child: Text('Junho')),
      DropdownMenuItem(value: '07', child: Text('Julho')),
      DropdownMenuItem(value: '08', child: Text('Agosto')),
      DropdownMenuItem(value: '09', child: Text('Setembro')),
      DropdownMenuItem(value: '10', child: Text('Outubro')),
      DropdownMenuItem(value: '11', child: Text('Novembro')),
      DropdownMenuItem(value: '12', child: Text('Dezembro')),
    ];
  }

  List<DropdownMenuItem<String>> getTypeUserOptions() {
    return const [
      DropdownMenuItem(value: '', child: Text('Nenhum')),
      DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('Super Administrador')),
      DropdownMenuItem(value: 'ADMIN', child: Text('Administrador')),
      DropdownMenuItem(value: 'USER', child: Text('Usuário')),
    ];
  }

  List<DropdownMenuItem<bool>> getTypeActiveOptions() {
    return const [
      DropdownMenuItem(value: true, child: Text('Ativo')),
      DropdownMenuItem(value: false, child: Text('Inativo')),
    ];
  }

  List<DropdownMenuItem<String>> getTypeAccountOptions() {
    return const [
      DropdownMenuItem(value: '', child: Text('Nenhum')),
      DropdownMenuItem(value: 'Pessoal', child: Text('Pessoal')),
      DropdownMenuItem(value: 'Comercial', child: Text('Comercial')),
    ];
  }
}