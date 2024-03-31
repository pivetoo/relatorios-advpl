#Include 'Protheus.ch'
#Include 'TopConn.ch'

/*{Protheus.doc} TRpt01
Este módulo permite imprimir um relatório de produtos ativos, com base em informações das tabelas SA1, SC5 e SC6. 
O relatório mostra o código, nome, estado, venda, produto, valor e número de cada produto ativo.

@author Rogério Piveto
@since 27/01/2024
@version 1.0
*/

User Function TRpt01()

    Local oReport
    Local cAlias := getNextAlias()

    oReport := RptStruc(cAlias)
    oReport:PrintDialog()

Return

Static Function RPrint(oReport, cAlias)

    Local oSecao1 := oReport:Section(1)

    oSecao1:BeginQuery()

        BeginSQL Alias cAlias
            SELECT
                A1_COD CODIGO
                , A1_NOME NOME
                , A1_EST ESTADO
                , C6_QTDVEN VENDA
                , C6_PRODUTO PRODUTO
                , C6_VALOR VALOR
                , C6_NUM NUMERO
            FROM %Table:SA1% SA1
                INNER JOIN %Table:SC5% SC5
                    ON SC5.D_E_L_E_T_ = ' '
                    AND SA1.A1_COD = SC5.C5_CLIENTE
                    AND C5_LOJACLI = SA1.A1_LOJA
                    AND C5_TIPO NOT IN ('D','B')
                    AND SA1.A1_LOJA = SC5.C5_LOJACLI
                INNER JOIN %Table:SC6% SC6
                    ON SC6.D_E_L_E_T_ = ' '
                    AND SC5.C5_NUM = SC6.C6_NUM
                    WHERE C6_PRODUTO = '000018'
        EndSql

    oSecao1:EndQuery()
    oReport:SetMeter((cAlias)->(RecCount()))

    oSecao1:Print()
Return

Static Function RptStruc(cAlias)

    Local cTitulo   := "Produtos ativos"
    Local cHelp     := "Permite imprimir relátorio de produtos"
    Local cNomArq   := "RELAT01_" + DToS(Date()) + StrTran(Time(),":","")
    Local oReport
    Local oSection1

    // Instanciando a classe TReport
    oReport := TReport():New(cNomArq, cTitulo,/**/, {|oReport|RPrint(oReport, cAlias)}, cHelp)

    // Seção
    oSection1 := TRSection():New(oReport, "Produtos",{"SA1", "SC5", "SC6"})

    TRCell():New(oSection1, "CODIGO", "SA1", "Código")
    TRCell():New(oSection1, "NOME", "SA1", "Nome")
    TRCell():New(oSection1, "ESTADO", "SA1", "Estado")
    TRCell():New(oSection1, "VENDA", "SA1", "Venda")
    TRCell():New(oSection1, "PRODUTO", "SA1", "Produto")
    TRCell():New(oSection1, "VALOR", "SA1", "Valor")
    TRCell():New(oSection1, "NUMERO", "SA1", "Número")

Return (oReport)
