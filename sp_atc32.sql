--Caso 12298   Pólizas con Cese de Coberturas
--Armando Moreno M. 19/12/2024

DROP procedure sp_atc32;
CREATE procedure sp_atc32(a_ano char(4), a_codagente CHAR(255) DEFAULT "*")
RETURNING char(5),char(50),char(3),char(50),char(10),char(50),char(20),char(10),dec(16,2), dec(16,2), dec(16,2),char(7),date,date,date,date,char(10),
          varchar(255),char(5),char(50);

define _periodo                                    char(7);
define _cod_ramo                                   char(3);
define _n_ramo,_n_contratante,_n_grupo,_n_corredor char(50);
define _cod_grupo,_cod_agente                      char(5);
define _cod_contratante,_no_factura,_estaus_poliza char(10);
define _no_documento                               char(20);
define _tipo 									   char(1);
define _prima_sus,_prima_ret,_prima_bru,_cobros    dec(16,2);
define _vig_ini_p,_vig_fin_p,_fecha_emision,_fecha_susc_end        date;
define v_filtros                                   varchar(255);

--SET DEBUG FILE TO "sp_jean18b";
--TRACE ON;

LET v_filtros = "";

IF a_codagente <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Corredor "||TRIM(a_codagente);
	LET _tipo = sp_sis04(a_codagente); -- Separa los valores del String
END IF

foreach
	select p.cod_grupo,
		   y.nombre,
		   p.cod_ramo,
		   h.nombre,
		   p.cod_contratante,
		   c.nombre,
		   p.no_documento,
		   e.no_factura,
		   e.prima_suscrita,
		   e.prima_retenida,
		   e.prima_bruta,
		   e.periodo,
		   p.vigencia_inic,
		   p.vigencia_final,
		   e.vigencia_inic,
		   decode(p.estatus_poliza,1,"Vigente",2,"Cancelada",3,"Vencida",4,"Anulada"),
		   g.cod_agente,
		   z.nombre,
		   e.fecha_emision
	  into _cod_grupo,
	       _n_grupo,
		   _cod_ramo,
		   _n_ramo,
		   _cod_contratante,
		   _n_contratante,
		   _no_documento,
		   _no_factura,
		   _prima_sus,
		   _prima_ret,
		   _prima_bru,
		   _periodo,
		   _vig_ini_p,
		   _vig_fin_p,
		   _fecha_emision,
		   _estaus_poliza,
		   _cod_agente,
		   _n_corredor,
		   _fecha_susc_end
      from endedmae e, emipomae p, emipoagt g, cligrupo y, prdramo h, cliclien c, agtagent z
     where e.no_poliza = p.no_poliza
       and p.no_poliza = g.no_poliza
       and p.cod_grupo = y.cod_grupo
	   and p.cod_ramo = h.cod_ramo
	   and g.cod_agente = z.cod_agente
	   and p.cod_contratante = c.cod_cliente
	   and e.actualizado = 1
	   and p.actualizado = 1
	   and e.cod_endomov = '032'
	   and g.cod_agente IN(SELECT codigo FROM tmp_codigos)
	   and e.periodo[1,4] >= a_ano
	   
	return _cod_grupo,_n_grupo,_cod_ramo,_n_ramo,_cod_contratante,_n_contratante,_no_documento,_no_factura,_prima_sus,_prima_ret,
           _prima_bru,_periodo,_vig_ini_p,_vig_fin_p,_fecha_emision,_fecha_susc_end,_estaus_poliza,v_filtros,_cod_agente,_n_corredor with resume;
	
end foreach
drop table tmp_codigos;
END PROCEDURE;