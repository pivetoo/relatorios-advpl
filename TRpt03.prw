#Include 'Protheus.ch'
#Include 'Topconn.ch'

/*{Protheus.doc} Trpt03
Este m�dulo permite imprimir um relat�rio de produtos e seus grupos, mostrando o c�digo, descri��o, tipo do produto, c�digo do grupo, descri��o do grupo e origem do grupo. 
Os dados s�o recuperados das tabelas SB1 e SBM.

@author Rog�rio Piveto
@since 23/02/2024
@version 1.0
*/

User Function TRpt03()

    Local oReport   := Nil
    Local cAlias    := getNextAlias()

    oReport := RptStruc(cAlias)
    oReport:PrintDialog()

Return

Static Function RPrint(oReport, cAlias)

    Local oSecao1 := oReport:Section(1)

    oSecao1:BeginQuery()
        BeginSQL Alias cAlias
            SELECT
                SB1.B1_COD AS CODIGO
                , SB1.B1_DESC AS DESCRICAO
                , SB1.B1_TIPO AS TIPO
                , SBM.BM_GRUPO GRUPO
                , SBM.BM_DESC BM_DESCRICAO
                , SBM.BM_PROORI BM_ORIGEM
            FROM %table:SB1% SB1
                INNER JOIN %table:SBM% SBM ON (
                    SBM.BM_FILIAL = '01'
                    AND SBM.D_E_L_E_T_ = ''
                )
            WHERE
                SB1.B1_FILIAL = ''
                AND SB1.D_E_L_E_T_ = ''
            ORDER BY
                SB1.B1_COD
        EndSql

    oSecao1:EndQuery()
    oReport:SetMeter((cAlias)->(RecCount()))

    oSecao1:Print()

Return

Static Function RptStruc(cAlias)

    Local cTitulo   := "Produtos e Grupos"
    Local cHelp     := "Permite imprimir rel�torio de produtos."
    Local cNomArq   := "RELATPG_" + DToS(Date()) + StrTran(Time(),":","")
    Local oReport
    Local oSection1

    oReport := TReport():New(cNomArq, cTitulo,/**/,{|oReport|RPrint(oReport, cAlias)}, cHelp)

    oSection1 := TRSection():New(oReport, "Produtos e Grupos", {"SB1","SBM"})

    TRCell():New(oSection1, "CODIGO", "SB1", "C�digo")
    TRCell():New(oSection1, "DESCRICAO", "SB1", "C�digo")
    TRCell():New(oSection1, "TIPO", "SB1", "C�digo")
    TRCell():New(oSection1, "GRUPO", "SBM", "C�digo")
    TRCell():New(oSection1, "BM_DESCRICAO", "SBM", "C�digo")
    TRCell():New(oSection1, "BM_ORIGEM", "SBM", "C�digo")

Return (oReport)
