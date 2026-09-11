### 1 - Pontos para validar com o cliente

Durante a reunião de validação, eu buscaria primeiro entender as regras de negócio e confirmar se o modelo de dados representa corretamente os processos da empresa. Em relação aos **fornecedores**, eu validaria se o cadastro precisa ser realizado obrigatoriamente antes de qualquer movimentação e quais informações devem ser armazenadas, como CNPJ, endereço, telefone, e-mail, inscrição estadual e condições de pagamento. Também verificaria se um mesmo produto pode possuir mais de um fornecedor e qual deve ser a interpretação do fornecedor registrado em `produtos_filial`: se representa o fornecedor principal, o último fornecedor utilizado ou um fornecedor exclusivo.

Na parte de **vendas e produtos**, eu confirmaria como funciona a identificação dos produtos em cenários com mais de uma filial, verificando se o `produto_id` é único globalmente ou se sua identificação é restrita a cada filial. Também seria importante definir qual tabela representa a fonte oficial da descrição do produto entre `produtos_filial`, `pedido_compra` e `entradas_mercadoria`. Além disso, eu verificaria se é possível vender ou comprar um produto que ainda não esteja previamente cadastrado em `produtos_filial`.

Em relação às **filiais**, eu verificaria se existe uma tabela específica para armazenar suas informações que ainda não esteja contemplada no modelo atual. Caso a empresa possua mais de uma filial, também validaria se existem transferências de estoque entre elas e, em caso afirmativo, onde essas movimentações são registradas e como devem impactar os saldos de estoque.

Para o **estoque**, eu buscaria esclarecer exatamente o significado do campo `estoque`, verificando se ele representa o saldo atual, o estoque disponível para venda ou o estoque físico. Também validaria se esse saldo deve ser atualizado automaticamente a partir das entradas de mercadoria e das vendas. Outro ponto importante seria entender como a empresa trata cancelamentos e estornos e se essas operações precisam gerar movimentações específicas para recompor o estoque.

Na **venda**, eu confirmaria se o `venda_id` identifica uma venda completa ou um item individual da venda. Também avaliaria se a data e o horário devem ser armazenados em um único campo temporal, em vez de permanecerem separados entre `data_emissao` e `horariomov`. Seria necessário esclarecer ainda o significado de `valor_unitario`, verificando se ele representa o preço efetivamente praticado após descontos, impostos e acréscimos. Por fim, eu validaria como devem ser tratados cancelamentos, devoluções e trocas, inclusive seus impactos financeiros e de estoque.

No processo de **pedido de compra**, eu buscaria entender se `pedido_id` e `ordem_compra` possuem funções diferentes ou se um deles deve ser considerado o identificador oficial do pedido. Também validaria se são permitidos recebimentos parciais e se a empresa aceita receber uma quantidade maior do que a originalmente solicitada. Outro ponto importante é saber se o pedido pode ser alterado depois que já houve recebimento de mercadorias.

Ainda nesse processo, eu esclareceria o significado do campo de data de entrega, verificando se representa uma previsão, um prazo acordado ou a data efetiva de entrega. Também validaria se a entrada de mercadorias pode ocorrer sem um pedido de compra prévio. Em relação ao `custo_unitario`, seria importante definir se ele já contempla frete, impostos, descontos e outras despesas relacionadas à aquisição. Por fim, eu verificaria como devem ser tratadas entradas originadas de devoluções, bonificações, ajustes de estoque e inventários, definindo se essas situações devem utilizar a mesma tabela ou processos distintos.

Entre **pedido de compra e entrada de mercadoria**, eu validaria se a quantidade efetivamente entregue em `pedido_compra` deve ser atualizada automaticamente a cada recebimento. Essa definição é importante principalmente para controlar recebimentos parciais, pedidos pendentes e eventuais divergências entre o que foi solicitado e o que realmente foi recebido.

Em relação aos **preços**, eu verificaria se é necessário manter um histórico das alterações de preço de venda e de custo, permitindo identificar quando e por que determinado valor foi alterado. Também buscaria esclarecer a relação entre `preco_unitario` e `preco_compra`, além de confirmar se existe alguma política específica para situações em que o preço de venda seja inferior ao preço de compra.

Para as **unidades de medida**, eu verificaria se existe conversão entre unidades de compra e venda, como nos casos em que um produto é comprado em caixas, mas comercializado individualmente. Essa regra é importante para garantir que as movimentações de estoque sejam calculadas corretamente.

Por fim, na parte de **qualidade e integridade dos dados**, eu validaria com o cliente quais campos são obrigatórios em cada processo e quais regras devem ser aplicadas para impedir registros inconsistentes. O objetivo seria garantir que o modelo reflita não apenas a estrutura técnica dos dados, mas também as regras efetivamente utilizadas pela empresa.

### 2 - Técnicas para garantir a exatidão e a precisão dos dados

Para garantir a exatidão e a precisão dos dados, eu adotaria validações em diferentes camadas, começando pela própria estrutura do banco de dados. A ideia seria assegurar que as informações estejam registradas no nível correto de detalhe, sem duplicidades, relacionamentos inválidos ou valores que não façam sentido para o processo de negócio.

No nível do banco, eu utilizaria **chaves primárias** para garantir a identificação única dos registros e **chaves estrangeiras** para assegurar que os relacionamentos entre as tabelas sejam válidos. Também utilizaria restrições de unicidade para evitar duplicidades em informações de negócio. No cadastro de fornecedores, por exemplo, o CNPJ poderia ser tratado como um campo único, além da possibilidade de armazenar outras informações relevantes para identificação e controle.

Outra medida seria definir **campos obrigatórios**, evitando que registros importantes sejam inseridos sem informações essenciais. Também aplicaria regras de validação para os valores, como impedir quantidades negativas quando elas não fizerem parte da regra de negócio e garantir que preços e custos assumam valores válidos.

Além das validações estruturais, eu realizaria **controles periódicos de consistência**, comparando os dados calculados pelo sistema com informações reais da operação. No caso do estoque, por exemplo, seria possível comparar o saldo calculado a partir das entradas, vendas, devoluções e ajustes com os resultados obtidos em inventários físicos. Essa comparação permitiria identificar divergências e investigar possíveis erros de registro ou problemas no processo.

### 3 - Consultas prontas para validação

Para a reunião de validação, eu deixaria previamente preparadas consultas SQL capazes de identificar possíveis inconsistências e facilitar a discussão com o cliente. Uma das primeiras consultas seria voltada para localizar **estoques negativos e valores monetários negativos**, permitindo verificar se esses resultados são esperados pelas regras de negócio ou se representam problemas de qualidade dos dados.

Também prepararia uma consulta para verificar se **todo produto vendido está devidamente cadastrado em `produtos_filial` para a respectiva filial**. Essa validação ajudaria a identificar vendas associadas a produtos inexistentes ou a produtos vinculados incorretamente a uma filial.

Outra consulta importante seria utilizada para identificar **pedidos cuja data prevista de entrega seja anterior à data do próprio pedido**. Esse tipo de inconsistência pode indicar erros de preenchimento ou problemas na interpretação dos campos de data.

Eu também prepararia uma comparação entre **a quantidade solicitada nos pedidos de compra e a quantidade efetivamente registrada nas entradas de mercadoria**. Com isso, seria possível identificar pedidos parcialmente recebidos, pedidos recebidos acima da quantidade solicitada ou outras divergências que precisem ser esclarecidas com o cliente.

Por fim, deixaria uma consulta para identificar **entradas de mercadorias que não possuem um pedido de compra correspondente**. Essa análise ajudaria a confirmar se a empresa permite recebimentos sem pedido prévio ou se esses registros representam uma inconsistência que precisa ser tratada no processo ou no modelo de dados.
