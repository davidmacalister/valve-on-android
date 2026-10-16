Desejo mudar a UI do script

Os itens título, ou seja a primeira linha dentro das acentos gráves são em negrito.
O elemento Exit/Sair são é vermelho.
Elementos em andamento como ⠧ Baixando são em azul e elementos bem sucedidos são em verde como ✓ Instalado com sucesso. [Textos dos estados possiveis em execução]
O nome de cada jogo tem a sua cor definida. [Menu de instalação] e [Menu de instalção em andamento]
Conta Steam usada em verde. [Menu de contas Steam]
O Item com ❯ deve ficar em negrito, representando que está em destaque.

```
                                      ≈                     ≈                                      
                                       ≈                   ≈                                       
                                        ≈≈  ≈≈≈≈≈≈≈≈≈≈≈  ≈≈                                        
                                       ÷÷÷÷≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈                                        
                                   =÷÷≈≈÷÷÷≈≈÷≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈                                     
                                  ÷÷÷÷≈≈≈÷≈≈÷÷÷÷≠≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈                                   
                                  ≈÷≈≈≠÷÷=÷÷≈÷≈÷≈≈≈≈≈≈≈≈   ≈≈≈≈≈≈                                  
                                 ≈≈÷≈÷÷÷÷÷÷÷=÷≈÷≈≈≈≈≈≈≈≈≈  ≈≈≈≈≈≈≈                                 
                                ≈≈÷÷÷≈÷≈≈÷≈÷÷÷÷÷≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈                                
                                ≈≈≈≈≈÷÷≈=÷≈≈÷≠≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈                                
                                        ÷÷÷                                                        

                                    Welcome to Valve on Android

                                      (press → to continue)
```


```
Select language

❯ English
  Русский
  Español
  Português (Brasil)
  
  Exit
=======================
↑/↓ navigate   → select
```

Menu principal, o que aparece logo ao inciar o script
```
Nota: leia o manual caso tenha alguma dúvida.

Menu principal

❯ Instalar jogos
  Gerenciar jogos
  Acessar manual
  Opções
  
  Sair
==========================
↑/↓ navegar   → selecionar
```

Menu de instalação, o que aparece ao apertar em [Instalar jogos] em (Menu principal)

Menus com (●) são possível de mais marcar mais de um item, ou apenas um, mas tem a bolinha pra mostrar qual estava já seleciona como nas opções, e exigem o botão confirmar.

E o menu deve ser dinâmico, se um jogo já está instalado, não há porque ele aparecer na lista.
```
Menu de instalação

Selecione os jogos que deseja

❯ (●) Half-Life
  ( ) Half-Life: Blue Shift
  ( ) Half-Life: Opposing Force
  ( ) Half-Life 2
  ( ) Half-Life 2: Episode One
  ( ) Half-Life 2: Episode Two
  ( ) Half-Life: Source
  ( ) Counter-Strike
  ( ) Counter-Strike: Source
  ( ) Day of Defeat: Source
  ( ) Team Fortress Classic
  ( ) Portal
  
  Confirmar
  Voltar
==========================
↑/↓ navegar   → selecionar
```

Menu de pergunta de versão, aparece ao selecionar algum jogo GoldSrc
```
Menu de instalação

Selecione a versão deseja para os jogos GoldSrc

❯ (●) Versão mais recente
  ( ) Versão anterior ao 25 Aniversário
  
  Confirmar
  Voltar
==========================
↑/↓ navegar   → selecionar
```

Menu de pergunta de login, aparece ao selecionar os itens do menu de instalação e não haja uma conta Steam salva
```
Menu de instalação

Entre na sua conta Steam

❯ Digite seu usuário:
  Digite sua senha:

  Confirmar
  Voltar
==========================
↑/↓ navegar   → selecionar
```

Menu de instalção em andamento, aparece ao quando as etapas de seleção e login estiverem prontas.
O menu deve exibir o nome do jogo sendo baixo, e abaixo do nome os itens de [Textos dos estados possiveis em execução]
Quanto ao Half-Life, considere ele como o [Jogo em andamente] ele é o jogo que está sendo baixando instalado, recebendo os pacotes de idioma caso tenha, ele assim que concluído, deve ser alterado para o nome do próximo jogo em que estará sendo baixado etc...
```
Menu de instalação

Half-Life
[Área de texto]
```

Menu de opções, aparece ao apertar em [Opções] em (Menu principal)
```
Opções

❯ Contas Steam
  Idiomas
  Exibir
  Voltar
==========================
↑/↓ navegar   → selecionar
```

Menu de contas Steam, aparece ao apertar em [Contas Steam] em (Opções)
```
Opções

Contas salvas:
menino_david
jv132
  
❯ Alterar conta usada
  Adicionar uma nova conta
  Remover contas salvas

  Voltar
==========================
↑/↓ navegar   → selecionar
```

Menu de Idioma da interface, aparece ao apertar em [Idioma da interface] em (Menu de idiomas)

Menu de idiomas, aparece ao apertar em [Idiomas] em (Opções)
```
Opções

❯ Idioma da interface
  Idioma dos jogos

  Voltar
==========================
↑/↓ navegar   → selecionar
```

Menu de Idioma da interface, aparece ao apertar em [Idioma da interface] em (Menu de idiomas)

```
Opções

Selecione o idioma deseja para a interface

❯ (●) English
  ( ) Русский
  ( ) Español
  ( ) Português (Brasil)
  
  Confirmar
  Voltar
==========================
↑/↓ navegar   → selecionar
```

Menu de Idioma de jogos, aparece ao apertar em [Idioma dos jogos] em (Menu de idiomas)

Nota: alguns idiomas não estão disponíveis em todos os jogos ou tem traduções de maneira oficial, então nesses casos são usadas traduções da comunidade quando disponíveis. (Ainda não sei como implementar as notas de maneira agradavél e generica nas interfaces)
```
Opções

Selecione o idioma deseja para os jogos

❯ (●) English
  ( ) Русский
  ( ) Español
  ( ) Français
  ( ) Deutsch
  ( ) Italiano
  ( ) Português (Brasil)
  
  Confirmar
  Voltar
==========================
↑/↓ navegar   → selecionar
```

Menu de Gerenciamento, aparece ao apertar em [Gerenciar jogos] em (Menu principal)

Ao clicar no Atualizar/Verificar integridade ele vai verificar de todos os jogos instalados, inclusive dos pacotes de idioma da comunidade.
```
Gerenciamento de jogos

❯ Desinstalar jogo
  Atualizar/Verificar integridade
  Voltar
==========================
↑/↓ navegar   → selecionar
```

Menu de desistalação, aparece ao apertar em [Desinstalar jogo] em (Gerenciar jogos)
```
Gerenciamento de jogos

Selecione os jogos que deseja desinstalar

❯ (●) Half-Life
  ( ) Half-Life: Blue Shift
  ( ) Half-Life: Opposing Force
  ( ) Half-Life 2
  ( ) Half-Life 2: Episode One
  ( ) Half-Life 2: Episode Two
  ( ) Half-Life: Source
  ( ) Counter-Strike
  ( ) Counter-Strike: Source
  ( ) Day of Defeat: Source
  ( ) Team Fortress Classic
  ( ) Portal
  
  Confirmar
  Voltar
==========================
↑/↓ navegar   → selecionar
```

Textos dos estados possiveis em execução

Os textos devem ocupar o [Área de texto] então quando o Baixado com sucesso aparecer ele deve aparecer no lugar do baixando por exemplo e assim para toda etapa.

esse ⠧ representa o braille spinner, e desejo ele animado.
```
✗ Ocorreu um erro.

⠧ Baixando dependecia: [nome da dependecia]
✓ Baixando com sucesso.

⠧ Baixando
✓ Baixando com sucesso.

⠧ Instalando
✓ Instalado com sucesso.

⠧ Baixando pacote de idioma oficial
✓ Baixando com sucesso.

⠧ Baixando pacote de idioma comunitário
✓ Baixando com sucesso.

⠧ Instalando pacote
✓ Instalado com sucesso.

⠧ Desinstalando
✓ Desinstalando com sucesso.


Aperte → para voltar ao menu principal
```

## Conderações finais
A IA deve dizer as áreas e textos que essa UI não está cobrindo
Confirmar a segurança das crédenciais
A opção de voltar deve voltar a tela que estavamos antes