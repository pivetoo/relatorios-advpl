#Include 'Totvs.ch'

/*/{Protheus.doc} RELATFUN
Cria a estrutura do relat�rio

@author Rogerio Piveto
@since 07/02/2024
@version 1
/*/

User Function TRpt04()

    Local oReport   := Nil
    Local aPergs    := {}
    Local aResps    := {}

    aAdd(aPergs, {1, "Codigo do cliente de", Space(TamSX3("A1_COD")[1]) ,,,,, 30, .F.})
    aAdd(aPergs, {1, "Codigo do cliente at�", Space(TamSX3("A1_COD")[1]),,,,, 30, .F.})

    If Parambox(aPergs, "Par�metros do relat�rio", @aResps,,,,,,,, .T., .T.)
        oReport := ReportDef(aResps)
        oReport:PrintDialog()
    EndIf

Return Nil

/*/{Protheus.doc} ReportDef
Define as propriedades do relat�rio

@author Rogerio Piveto
@since 08/02/2024
@version 1
/*/

Static Function ReportDef(aResps)

    Local oReport       := Nil
    Local oSection      := Nil
    Local cAliasTop     := ""
    Local cNomArq       := "RELAT01_" + DToS(Date()) + StrTran(Time(),":","")
    Local cTitulo       := "Vendas e Produtos"

    oReport := TReport():New(cNomArq, cTitulo, "", {|oReport| ReportPrint(oReport, @cAliasTop, aResps)}, "Este programa tem como objetivo imprimir informa��es do relat�rio")
    oReport:SetLandscape()

    oSection := TRSection():New(oReport, cTitulo, {"SA1", "SC5", "SC6"})

    TRCell():New(oSection, "A1_COD"         , cAliasTop , "C�digo do cliente"   ,,,, {||(cAliasTop)->A1_COD})
    TRCell():New(oSection, "A1_NOME"        , cAliasTop , "Nome do Cliente"     ,,,, {||(cAliasTop)->A1_NOME})
    TRCell():New(oSection, "C6_QTDVEN"      , cAliasTop , "Qtd. vendida"        ,,,, {||(cAliasTop)->C6_QTDVEN})
    TRCell():New(oSection, "C6_PRODUTO"     , cAliasTop , "C�digo do produto"   ,,,, {||(cAliasTop)->C6_PRODUTO})
    TRCell():New(oSection, "C6_VALOR"       , cAliasTop , "Valor"               ,,,, {||(cAliasTop)->C6_VALOR})
    TRCell():New(oSection, "C6_NUM"         , cAliasTop , "N�mero. do pedido"   ,,,, {||(cAliasTop)->C6_NUM})

Return oReport

/*/{Protheus.doc} ReportPrint
Construir a Consulta SQL, Imprimir o relat�rio

@author Rogerio Piveto
@since 08/02/2024
@version 1
/*/
Static Function ReportPrint(oReport, cAliasTop, aResps)

    Local oSection  := oReport:Section(1)
    Local cQuery    := ""
    Local cCodDe    := aResps[1]
    Local cCodAte   := aResps[2]

    cQuery += "SELECT" + CRLF
    cQuery += "A1_COD" + CRLF
    cQuery += ", A1_NOME" + CRLF
    cQuery += ", A1_EST" + CRLF
    cQuery += ", C6_QTDVEN" + CRLF
    cQuery += ", C6_PRODUTO" + CRLF
    cQuery += ", C6_VALOR" + CRLF
    cQuery += ", C6_NUM" + CRLF
    cQuery += "FROM " + RetSqlName("SA1") + " SA1 " + CRLF 
    cQuery += "INNER JOIN " + RetSqlName("SC5") + " SC5 " + CRLF
    cQuery += "ON SC5.D_E_L_E_T_ = ' '" + CRLF
    cQuery += "AND SA1.A1_COD = SC5.C5_CLIENTE" + CRLF
    cQuery += "AND C5_LOJACLI = SA1.A1_LOJA" + CRLF
    cQuery += "AND C5_TIPO NOT IN ('D','B')" + CRLF
    cQuery += "AND SA1.A1_LOJA = SC5.C5_LOJACLI" + CRLF
    cQuery += "INNER JOIN " + RetSqlName("SC6") + " SC6 " + CRLF
    cQuery += "ON SC6.D_E_L_E_T_ = ' '" + CRLF
    cQuery += "AND SC5.C5_NUM = SC6.C6_NUM" + CRLF
    cQuery += "WHERE C6_PRODUTO = '000018'" + CRLF

    If !Empty(cCodDe) .Or. !Empty(cCodAte)
        cQuery += "GROUP BY" + CRLF
    EndIf

    cQuery += "A1_COD" + CRLF
    cQuery += ", A1_NOME" + CRLF
    cQuery += ", A1_EST" + CRLF
    cQuery += ", C6_QTDVEN" + CRLF
    cQuery += ", C6_PRODUTO" + CRLF
    cQuery += ", C6_VALOR" + CRLF
    cQuery += ", C6_NUM" + CRLF
    cQuery += ", A1_EST" + CRLF


    cAliasTop := MPSysOpenQuery(cQuery)

    If(cAliasTop)->(EOF())
        Alert("Nenhum dado com os par�metros informados!")
    Else
        oSection:Init()
        While(cAliasTop)->(!EOF())
            oSection:PrintLine()
            (cAliasTop)->(DBSkip())
        EndDo

        (cAliasTop)->(dbCloseArea())
        oSection:Finish()
    EndIf

Return
