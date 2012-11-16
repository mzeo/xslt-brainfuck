<?xml version="1.0" encoding="ISO-8859-1"?>

<!DOCTYPE xsl:transform [
		<!ENTITY null "'000,'">
		<!ENTITY decode-data-head "number(substring($data, 1, 1))*64+number(substring($data, 2, 1))*8+number(substring($data, 3, 1))">
		<!ENTITY encode-result "concat(floor($result div 64) mod 8, floor($result div 8) mod 8, $result mod 8, ',')">
]>

<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bf="https://github.com/mzeo/xslt-brainfuck">

	<!-- Setup output type -->
	<xsl:output method="xml" version="1.0"
		encoding="utf-8" indent="yes"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
		doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

	<!-- Copy everything as default -->
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<!-- the fractal tag -->
	<xsl:template match="bf:brainfuck">
		<xsl:variable name="null-2" select="concat(&null;, &null;)"/>
		<xsl:variable name="null-8" select="concat($null-2, $null-2, $null-2, $null-2)"/>
		<xsl:variable name="null-32" select="concat($null-8, $null-8, $null-8, $null-8)"/>
		<xsl:variable name="null-128" select="concat($null-32, $null-32, $null-32, $null-32)"/>

		<xsl:call-template name="bf:step">
			<xsl:with-param name="pc" select="0"/>
			<xsl:with-param name="data" select="$null-32"/>
			<xsl:with-param name="stack" select="''"/>
			<xsl:with-param name="ip" select="1"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="bf:step">
		<xsl:param name="pc"/>
		<xsl:param name="data"/>
		<xsl:param name="stack"/>
		<xsl:param name="ip"/>

		<xsl:variable name="next-pc" select="$pc + 1"/>
		<xsl:variable name="main" select="bf:main[text()]"/>
		<xsl:variable name="op" select="substring($main, $next-pc, 1)"/>

		<xsl:choose>
			<xsl:when test="$op = '&gt;'">
				<xsl:call-template name="bf:inc-data-ptr">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$op = '&lt;'">
				<xsl:call-template name="bf:dec-data-ptr">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$op = '['">
				<xsl:call-template name="bf:while-begin">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$op = ']'">
				<xsl:call-template name="bf:while-end">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$op = '+'">
				<xsl:call-template name="bf:inc-data">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$op = '-'">
				<xsl:call-template name="bf:dec-data">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$op = '.'">
				<xsl:call-template name="bf:output">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$op = ','">
				<xsl:call-template name="bf:input">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$op = '!'">
				<xsl:call-template name="bf:step">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$pc &gt; string-length($main)">
			</xsl:when>

			<!-- Skip unknown characters -->
			<xsl:otherwise>
				<xsl:call-template name="bf:step">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="bf:inc-data-ptr">
		<xsl:param name="pc"/>
		<xsl:param name="data"/>
		<xsl:param name="stack"/>
		<xsl:param name="ip"/>

		<xsl:variable name="head-raw" select="substring($data, 1, 4)"/>
		<xsl:variable name="tail-raw" select="substring($data, 5)"/>

		<!-- Continue -->
		<xsl:call-template name="bf:step">
			<xsl:with-param name="pc" select="$pc"/>
			<xsl:with-param name="data" select="concat($tail-raw, $head-raw)"/>
			<xsl:with-param name="stack" select="$stack"/>
			<xsl:with-param name="ip" select="$ip"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="bf:dec-data-ptr">
		<xsl:param name="pc"/>
		<xsl:param name="data"/>
		<xsl:param name="stack"/>
		<xsl:param name="ip"/>

		<xsl:variable name="head-raw" select="substring($data, string-length($data)-3, 4)"/>
		<xsl:variable name="tail-raw" select="substring($data, 1, string-length($data)-4)"/>

		<!-- Continue -->
		<xsl:call-template name="bf:step">
			<xsl:with-param name="pc" select="$pc"/>
			<xsl:with-param name="data" select="concat($head-raw, $tail-raw)"/>
			<xsl:with-param name="stack" select="$stack"/>
			<xsl:with-param name="ip" select="$ip"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="bf:inc-data">
		<xsl:param name="pc"/>
		<xsl:param name="data"/>
		<xsl:param name="stack"/>
		<xsl:param name="ip"/>

		<xsl:variable name="head" select="&decode-data-head;" />
		<xsl:variable name="tail" select="substring($data, 5)"/>
		<xsl:variable name="result" select="($head + 1) mod 256" />

		<!-- Continue -->
		<xsl:call-template name="bf:step">
			<xsl:with-param name="pc" select="$pc"/>
			<xsl:with-param name="data" select="concat(&encode-result;, $tail)"/>
			<xsl:with-param name="stack" select="$stack"/>
			<xsl:with-param name="ip" select="$ip"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="bf:dec-data">
		<xsl:param name="pc"/>
		<xsl:param name="data"/>
		<xsl:param name="stack"/>
		<xsl:param name="ip"/>

		<xsl:variable name="head" select="&decode-data-head;" />
		<xsl:variable name="tail" select="substring($data, 5)"/>
		<xsl:variable name="result" select="($head + 255) mod 256" />

		<!-- Continue -->
		<xsl:call-template name="bf:step">
			<xsl:with-param name="pc" select="$pc"/>
			<xsl:with-param name="data" select="concat(&encode-result;, $tail)"/>
			<xsl:with-param name="stack" select="$stack"/>
			<xsl:with-param name="ip" select="$ip"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="bf:while-begin">
		<xsl:param name="pc"/>
		<xsl:param name="data"/>
		<xsl:param name="stack"/>
		<xsl:param name="ip"/>

		<xsl:variable name="head" select="&decode-data-head;" />

		<xsl:choose>
			<xsl:when test="$head = 0">
				<!-- Continue -->
				<xsl:call-template name="bf:while-skip">
					<xsl:with-param name="pc" select="$pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:otherwise>
				<!-- Continue -->
				<xsl:call-template name="bf:step">
					<xsl:with-param name="pc" select="$pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="concat(number($pc), ',', $stack)"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="bf:while-end">
		<xsl:param name="pc"/>
		<xsl:param name="data"/>
		<xsl:param name="stack"/>
		<xsl:param name="ip"/>

		<xsl:variable name="stack-head" select="number(substring-before($stack, ','))"/>
		<xsl:variable name="stack-tail" select="substring-after($stack, ',')"/>

		<xsl:call-template name="bf:while-begin">
			<xsl:with-param name="pc" select="$stack-head"/>
			<xsl:with-param name="data" select="$data"/>
			<xsl:with-param name="stack" select="$stack-tail"/>
			<xsl:with-param name="ip" select="$ip"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="bf:while-skip">
		<xsl:param name="pc"/>
		<xsl:param name="data"/>
		<xsl:param name="stack"/>
		<xsl:param name="ip"/>
		<xsl:param name="level" select="1"/>

		<xsl:variable name="next-pc" select="$pc + 1"/>
		<xsl:variable name="main" select="bf:main[text()]"/>
		<xsl:variable name="op" select="substring($main, $next-pc, 1)"/>

		<xsl:choose>
			<xsl:when test="$op = '['">
				<xsl:call-template name="bf:while-skip">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
					<xsl:with-param name="level" select="$level + 1"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$op = ']' and $level = 1">
				<!-- Continue -->
				<xsl:call-template name="bf:step">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$op = ']'">
				<xsl:call-template name="bf:while-skip">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
					<xsl:with-param name="level" select="$level - 1"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$pc &gt; string-length($main)">
				<xsl:value-of select="Error"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:call-template name="bf:while-skip">
					<xsl:with-param name="pc" select="$next-pc"/>
					<xsl:with-param name="data" select="$data"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip"/>
					<xsl:with-param name="level" select="$level"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:variable name="ascii-table" select="'&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#10;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255;&#255; !&quot;#$%&amp;&#255;()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~&#127;'" />

	<xsl:template name="bf:output">
		<xsl:param name="pc"/>
		<xsl:param name="data"/>
		<xsl:param name="stack"/>
		<xsl:param name="ip"/>

		<xsl:variable name="head" select="&decode-data-head;" />
		<xsl:value-of select="substring($ascii-table, $head + 1, 1)"/>

		<!-- Continue -->
		<xsl:call-template name="bf:step">
			<xsl:with-param name="pc" select="$pc"/>
			<xsl:with-param name="data" select="$data"/>
			<xsl:with-param name="stack" select="$stack"/>
			<xsl:with-param name="ip" select="$ip"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="bf:input">
		<xsl:param name="pc"/>
		<xsl:param name="data"/>
		<xsl:param name="stack"/>
		<xsl:param name="ip"/>

		<xsl:variable name="char" select="substring(bf:input[text()], $ip, 1)"/>
		<xsl:variable name="tail" select="substring($data, 5)"/>

		<xsl:choose>
			<xsl:when test="$char != ''">
				<xsl:variable name="result" select="string-length(substring-before($ascii-table, $char))"/>

				<!-- Continue -->
				<xsl:call-template name="bf:step">
					<xsl:with-param name="pc" select="$pc"/>
					<xsl:with-param name="data" select="concat(&encode-result;, $tail)"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip + 1"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:otherwise>
				<!-- assume 255 marks eof -->
				<xsl:variable name="result" select="255"/>

				<!-- Continue -->
				<xsl:call-template name="bf:step">
					<xsl:with-param name="pc" select="$pc"/>
					<!-- <xsl:with-param name="data" select="$data"/> -->
					<xsl:with-param name="data" select="concat(&encode-result;, $tail)"/>
					<xsl:with-param name="stack" select="$stack"/>
					<xsl:with-param name="ip" select="$ip + 1"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:transform>

