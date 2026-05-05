# Crud-Basico

Você deverá fazer um App em flutter que realiza um CRUD para a seguinte aplicação: App de
tarefas. O objetivo é criar um aplicativo onde o usuário possa cadastrar, visualizar, editar e excluir
tarefas utilizando flutter.

Cada tarefa deve ter no mínimo os seguintes atributos: id, título, descrição, data prevista para
realização, importante (boolean), realizada(boolean).

Requisitos e item que serão avaliados: 

1. Crie um atributo a mais para a sua tarefa (de escolha de cada estudante).

2. O id e a descrição serão mostrados somente na tela de detalhes, nessa tela você poderá
realizar a tarefa.

3. Na tela de inserir e editar você deverá trabalhar com datas. Para tanto utilize o widget
ShowDatePicker do flutter (https://api.flutter.dev/flutter/material/showDatePicker.html).

4. Na tela de edição você poderá editar os demais campos, mas não realizar a tarefa.

5. Deve ser feita a persistência com SQLite: crie um arquivo que gerencia as transações com o
banco, faça a classe de modelo ter um factory fromMap e um método toMap para facilitar
acesso ao banco de dados. Utilize id auto gerado pelo banco. Lembre-se que a data deve ser
armazenada como Text, pesquise como você pode fazer essa transformação.

6. Deve ser feito gerenciamento de estado com o Provider (não precisa ser todas informações
gerenciadas com o Provider, mas a que se demonstrarem mais relevantes).

7. Utilização de navegação com rotas nomeadas. Faça uma tela inicial de boas vindas que
mostra o título e data prevista da tarefa mais perto de ser vencida. 

8. Para tela de listagem, deve ser feito filtros por tarefas: importantes ou não, realizadas ou
não, atrasadas ou não. Tente fazer utilizando o TabBar na sua AppBar (https://api.flutter.dev/
flutter/material/TabBar-class.html). Caso deseje a faça na parte inferior da tela do App.

9. Widgets Próprios: criação dos seus próprios componentes reutilizáveis (ex: um card de item
personalizado ou um botão estilizado) para promover o reuso de código.

10. Organização dos arquivos: separe em pastas, para os seus componentes, para as providers,
para as models, para as telas etc.

11. Deverá ser realizados em partes: será visto o histórico dos commits no seu repositório do
github (espera-se que ao menos três commits: por exemplo nos dias da aulas para realizar e
no dia da entrega 30/04, 07/05 e 08/05.

12. Entrega e apresentação para o professor: sexta dia 08/05. Deverá ser enviado o link do seu
repositório pelo moodle
