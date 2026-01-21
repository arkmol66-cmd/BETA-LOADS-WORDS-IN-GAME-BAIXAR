===============================================================================
                    DST DISTRIBUTED WORLD SERVER MOD
                          Sistema de Distribuição Inteligente
===============================================================================

🎮 DESCRIÇÃO
============
Este mod para Don't Starve Together implementa um sistema revolucionário que 
divide automaticamente o processamento do mundo entre diferentes servidores 
baseado na localização dos jogadores e plataforma utilizada.

O sistema detecta onde cada jogador está (mundo superior ou cavernas) e 
distribui a carga de processamento de forma inteligente, otimizando a 
performance para todos os participantes.

🚀 FUNCIONALIDADES PRINCIPAIS
==============================
✅ Detecção automática de mundo (Superior/Cavernas)
✅ Divisão inteligente de carga baseada na plataforma
✅ Balanceamento automático quando há muitos jogadores
✅ Interface visual em tempo real (pressione "/")
✅ Sistema de rede distribuída entre servidores
✅ Monitoramento contínuo de performance
✅ Transições automáticas entre mundos
✅ Otimização baseada no número de jogadores

🎯 COMO FUNCIONA
================
1. DETECÇÃO AUTOMÁTICA
   - O mod detecta automaticamente se você está no mundo superior ou cavernas
   - Monitora transições entre mundos em tempo real
   - Adapta o processamento baseado na localização

2. DISTRIBUIÇÃO INTELIGENTE
   - Windows: Processa cargas mais pesadas (mundo superior)
   - Mac/Linux: Processa cargas mais leves (cavernas)
   - 1 jogador: Roda tudo em uma máquina
   - 2+ jogadores: Divide automaticamente entre plataformas

3. BALANCEAMENTO DINÂMICO
   - Monitora carga de cada servidor
   - Redistribui jogadores quando necessário
   - Otimiza performance automaticamente
   - Mais jogadores = mais divisões = mais leve para todos

📦 INSTALAÇÃO
=============
1. BAIXAR O MOD
   - Baixe a pasta "MOD_DST" completa
   - Certifique-se de ter todos os arquivos

2. INSTALAR NO DST
   - Localize a pasta de mods do Don't Starve Together:
     * Steam: steamapps/common/Don't Starve Together/mods/
     * Documentos: Documents/Klei/DoNotStarveTogether/mods/
   
   - Copie a pasta "MOD_DST" para a pasta de mods
   - Renomeie para "DistributedWorldServer"

3. ATIVAR NO JOGO
   - Abra Don't Starve Together
   - Vá em "Mods"
   - Encontre "Distributed World Server (.NET)"
   - Clique em "Enable"
   - Configure as opções se desejar

4. TESTAR
   - Entre em um mundo
   - Pressione "/" para abrir a interface
   - Verifique se o sistema está funcionando

🖥️ INTERFACE VISUAL
===================
Pressione "/" a qualquer momento no jogo para ver:

🌍 MUNDO ATUAL
   - Mostra se você está no Mundo Superior ou Cavernas
   - Detecta transições automaticamente

👥 JOGADORES
   - Quantidade de jogadores conectados
   - Número de partições ativas

⚖️ BALANCEAMENTO
   - Status: Ativo ✅ ou Inativo ⏸️
   - Indica se o sistema está otimizando

📊 DISTRIBUIÇÃO DE CARGA
   - Percentual de processamento por mundo
   - Mostra como a carga está dividida

🖥️ SERVIDORES
   - Quantos servidores estão conectados
   - Status online/offline

⚡ PERFORMANCE
   - Otimizado 🟢: Sistema funcionando perfeitamente
   - Balanceado 🟡: Performance adequada
   - Sobrecarregado 🔴: Necessita otimização

⚙️ CONFIGURAÇÕES
================
O mod oferece várias opções configuráveis:

DETECÇÃO AUTOMÁTICA DE MUNDO
   - Ativado: Detecta automaticamente onde você está
   - Desativado: Usa configuração manual

PRIORIDADE DE PLATAFORMA
   - Windows: Pega cargas mais pesadas
   - Linux: Cargas médias
   - Mac: Cargas mais leves
   - Auto: Detecta automaticamente

BALANCEAMENTO DE CARGA
   - Ativado: Sistema redistribui carga automaticamente
   - Desativado: Mantém configuração fixa

SÓ MUNDO ATIVO
   - Ativado: Processa apenas onde há jogadores
   - Desativado: Processa todos os mundos

MODO DEBUG
   - Ativado: Mostra mensagens detalhadas no console
   - Desativado: Apenas mensagens importantes

🎮 EXEMPLOS DE USO
==================
CENÁRIO 1: JOGANDO SOZINHO
   - Sistema detecta que há apenas 1 jogador
   - Roda tudo na sua máquina
   - Otimiza processamento baseado na sua localização

CENÁRIO 2: 2 JOGADORES (VOCÊ + AMIGO)
   - Você (Windows): Sistema atribui mundo superior
   - Amigo (Mac): Sistema atribui cavernas
   - Cada um processa apenas sua parte
   - Performance otimizada para ambos

CENÁRIO 3: GRUPO GRANDE (3+ JOGADORES)
   - Sistema divide em múltiplas partições
   - Distribui baseado na plataforma de cada um
   - Quanto mais jogadores, mais divisões
   - Carga fica mais leve para todos

CENÁRIO 4: TODOS NO WINDOWS
   - Sistema detecta que todos usam Windows
   - Host (dono do mundo) processa tudo
   - Outros se conectam como clientes
   - Fallback automático para modo tradicional

📊 MONITORAMENTO
================
O sistema monitora continuamente:

JOGADORES
   - Entrada e saída de jogadores
   - Localização atual (mundo superior/cavernas)
   - Plataforma utilizada (Windows/Mac/Linux)
   - Transições entre mundos

SERVIDORES
   - Status online/offline
   - Carga de processamento
   - Número de jogadores por servidor
   - Latência de rede

PERFORMANCE
   - CPU e memória utilizadas
   - Eficiência da distribuição
   - Necessidade de rebalanceamento
   - Otimizações automáticas

🔧 ARQUITETURA TÉCNICA
======================
O mod é composto por módulos especializados:

DISTRIBUTED_WORLD_MANAGER.LUA
   - Gerencia detecção de mundos
   - Controla partições ativas
   - Monitora jogadores conectados

LOAD_BALANCER.LUA
   - Sistema de balanceamento inteligente
   - Algoritmos de otimização
   - Redistribuição automática

NETWORK_MANAGER.LUA
   - Comunicação entre servidores
   - Sistema de heartbeat
   - Sincronização de dados

DISTRIBUTED_UI.LUA
   - Interface visual em tempo real
   - Animações e feedback
   - Controles do usuário

🐛 SOLUÇÃO DE PROBLEMAS
=======================
PROBLEMA: Mod não aparece na lista
SOLUÇÃO: 
   - Verifique se a pasta está em "mods/"
   - Certifique-se que o nome é "DistributedWorldServer"
   - Verifique se todos os arquivos estão presentes

PROBLEMA: Interface não abre com "/"
SOLUÇÃO:
   - Certifique-se que não está em chat ou console
   - Tente pressionar "/" novamente
   - Verifique se o mod está ativado

PROBLEMA: Sistema não detecta mundo
SOLUÇÃO:
   - Ative "Detecção Automática" nas configurações
   - Entre e saia do mundo para forçar detecção
   - Verifique modo debug para mensagens detalhadas

PROBLEMA: Balanceamento não funciona
SOLUÇÃO:
   - Certifique-se que há 2+ jogadores
   - Ative "Balanceamento de Carga" nas configurações
   - Aguarde alguns segundos para o sistema processar

📝 LOGS E DEBUG
===============
Para ativar logs detalhados:
1. Configure "Modo Debug" para "Ativado"
2. Reinicie o servidor
3. Verifique console do jogo para mensagens como:
   [DistributedWorldServer] Mensagem informativa
   [DistributedWorldServer DEBUG] Mensagem detalhada

🤝 COMPATIBILIDADE
==================
✅ Don't Starve Together (todas as versões recentes)
✅ Windows, Mac, Linux
✅ Servidor dedicado
✅ Multiplayer (2-20+ jogadores)
✅ Mods compatíveis (não conflita com outros mods)
❌ Don't Starve (single player não suportado)

🔄 ATUALIZAÇÕES
===============
Versão 1.0.0 (Atual):
   - Sistema completo de distribuição
   - Interface visual interativa
   - Balanceamento automático
   - Detecção de transições
   - Suporte multiplataforma

Futuras atualizações podem incluir:
   - Integração com servidores externos
   - Métricas avançadas de performance
   - Configurações mais granulares
   - Suporte para mais plataformas

📞 SUPORTE
==========
Para problemas, dúvidas ou sugestões:

1. VERIFICAÇÃO BÁSICA
   - Ative modo debug
   - Pressione "/" para verificar status
   - Verifique logs no console

2. INFORMAÇÕES ÚTEIS
   - Versão do DST
   - Sistema operacional
   - Número de jogadores
   - Configurações do mod
   - Mensagens de erro específicas

3. PASSOS PARA REPORTAR
   - Descreva o problema detalhadamente
   - Inclua screenshots da interface (/)
   - Copie mensagens de erro do console
   - Informe configurações utilizadas

===============================================================================
                              DIVIRTA-SE!
        O mod está pronto para otimizar sua experiência no DST!
===============================================================================