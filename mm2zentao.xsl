<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" encoding="UTF-8"/>
	
	<xsl:variable name="CaseTitleTag">_P</xsl:variable>
	<xsl:variable name="sQuote">"</xsl:variable>
	<xsl:variable name="dQuotes">""</xsl:variable>
	
	<!-- 字符串替换模板库 -->
	<xsl:template name="string-replace-all">
		<xsl:param name="text"/>
		<xsl:param name="replace"/>
		<xsl:param name="by"/>
		<xsl:choose>
			<xsl:when test="contains($text, $replace)">
				<xsl:value-of select="substring-before($text,$replace)"/>
				<xsl:value-of select="$by"/>
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="substring-after($text,$replace)"/>
					<xsl:with-param name="replace" select="$replace"/>
					<xsl:with-param name="by" select="$by"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- 递归输出完整用例标题的命名模板，例子：“根节点-一级节点-用例名” -->
	<xsl:template match="node" mode="print-full-casetitle">

		<xsl:apply-templates select="parent::node" mode="print-full-casetitle"/>
		
		
		<!-- freemind普通节点 -->
		<xsl:if test="@TEXT">
			<xsl:call-template name="string-replace-all">
				<xsl:with-param name="text" select="concat(@TEXT, '-')"/>
				<xsl:with-param name="replace" select="$sQuote"/>
				<xsl:with-param name="by" select="$dQuotes"/>
			</xsl:call-template>
			<!-- <xsl:value-of select="concat(@TEXT, '-')"/> -->
		</xsl:if>
		
		<!-- freemind长节点（富文本） -->
		<xsl:if test="./richcontent[@TYPE='NODE']">
			<xsl:call-template name="string-replace-all">
				<xsl:with-param name="text" select="concat(normalize-space(richcontent[@TYPE='NODE']), '-')"/>
				<xsl:with-param name="replace" select="$sQuote"/>
				<xsl:with-param name="by" select="$dQuotes"/>
			</xsl:call-template>
			<!-- <xsl:value-of select="concat(normalize-space(richcontent[@TYPE='NODE']), '-')"/> -->
		</xsl:if>
	</xsl:template>
	
	<!--
	<xsl:template match="node[@TEXT]" mode="print-full-step">
		
		<xsl:if test="not(parent::node[contains(@TEXT, $CaseTitleTag)])">
			<xsl:apply-templates select="parent::node[@TEXT]" mode="print-full-step"/>
		</xsl:if>
		
		<xsl:call-template name="string-replace-all">
			<xsl:with-param name="text" select="concat(@TEXT, '-')"/>
			<xsl:with-param name="replace" select="$sQuote"/>
			<xsl:with-param name="by" select="$dQuotes"/>
		</xsl:call-template>
	</xsl:template>
	-->
	<!-- xsl:template match="/" mode="print-full-casetitle" / -->
	
	<!-- 主模板 -->
	<xsl:template match="/">
	
		<!-- 只匹配包含指定标签的用例节点， -->
		<xsl:for-each select="//node[contains(@TEXT, $CaseTitleTag)]">
			
			<!-- 按照csv格式用引号括起每个字段值 -->
			<xsl:text>"</xsl:text>
			
			<!-- 从脑图的根节点下面开始按层级给用例编号 -->
			<xsl:number level="multiple" format="1. " from="/map/node"/>
			<!-- 递归输出完整用例标题 -->
			<xsl:apply-templates select="parent::node" mode="print-full-casetitle"/>
			
			<!-- 按照csv格式把标题中的每个引号替换为2个引号 -->
			<xsl:call-template name="string-replace-all">
				<xsl:with-param name="text" select="@TEXT"/>
				<xsl:with-param name="replace" select="$sQuote"/>
				<xsl:with-param name="by" select="$dQuotes"/>
			</xsl:call-template>
			<!-- <xsl:value-of select="@TEXT"/> -->
			<!-- 按照csv格式用引号结束字段内容 -->
			<xsl:text>"</xsl:text>
			
			<!-- 如果用例标题下面有非空节点，视为步骤 -->
			<xsl:if test="node[@TEXT]">
				
				<!-- 如果步骤已经编号，比如从禅道导出的csv文件直接复制步骤字段内容到脑图中，则跳过对步骤编号 -->
				<xsl:variable name="skipNumber" select='node[starts-with(@TEXT, "1. ")]'/>

			
				<!-- 按照csv格式新增一列，引号开始 -->
				<xsl:text>,"</xsl:text>
				
				<xsl:for-each select="node[@TEXT]">
				
					
					<xsl:if test="not($skipNumber)">
						<!-- 按禅道csv格式进行编号 -->
						<xsl:number format="1. "/>
					</xsl:if>
					
					<!--
						<xsl:if test="not(parent::node[contains(@TEXT, $CaseTitleTag)])">
							<xsl:apply-templates select="parent::node[@TEXT]" mode="print-full-step"/>
						</xsl:if>
					-->
					
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="@TEXT"/>
						<xsl:with-param name="replace" select="$sQuote"/>
						<xsl:with-param name="by" select="$dQuotes"/>
					</xsl:call-template>
					
					<!-- 步骤不能使用长节点 -->				
					<!-- 按照禅道格式步骤之间插入换行 -->
					<xsl:if test="position()!=last()">
						<xsl:text>&#xa;</xsl:text>
					</xsl:if>
					
				</xsl:for-each>
				<xsl:text>"</xsl:text>
			</xsl:if>
			
			<xsl:text>&#xa;</xsl:text>
		</xsl:for-each>
		<!--
		<xsl:for-each select="//node/richcontent[@TYPE='NODE']">
			<xsl:text>"</xsl:text>
			<xsl:apply-templates select=".." mode="print-full-casetitle"/>
				
			<xsl:call-template name="string-replace-all">
				<xsl:with-param name="text" select="normalize-space(richcontent[@TYPE='NODE'])"/>
				<xsl:with-param name="replace" select="$sQuote"/>
				<xsl:with-param name="by" select="$dQuotes"/>
			</xsl:call-template>
			<xsl:value-of select="@TEXT"/> 
			<xsl:text>"&#xa;</xsl:text>
		</xsl:for-each>
		-->
	</xsl:template>



</xsl:stylesheet>


<!--



	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
 
	<xsl:template name="linebreak">
		<xsl:text>
		</xsl:text>
	</xsl:template>

	<xsl:template match="map">
		<xsl:apply-templates select="child::node"/>
	</xsl:template>

	<xsl:template match='node[contains(@TEXT, "_P")]'>
		<xsl:param name="caseName"><xsl:value-of select="@TEXT"/></xsl:param>
		
		<xsl:if test="parent::node()">
			<xsl:call-template name="getPrefix">
				<xsl:with-param name="ancestorNodeNames" select="ancestor::*/@TEXT"/>
			</xsl:call-template>
		</xsl:if>
    
		<xsl:value-of select="@TEXT"/>
     
		<xsl:call-template name="linebreak"/>
		
	</xsl:template>
	 
	<xsl:template name="getPrefix">
		<xsl:param name="commaCount">0</xsl:param>
		<xsl:if test="$commaCount > 0">,<xsl:call-template name="writeCommas">
				<xsl:with-param name="commaCount" select="$commaCount - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
-->

 	  	 
