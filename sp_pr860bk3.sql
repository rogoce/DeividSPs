------------------------------------------------
--      TOTALES DE PRODUCCION POR             --  
--         CONTRATO DE REASEGURO              --
---  Yinia M. Zamora - octubre 2000 - YMZM	  --
---  Ref. Power Builder - d_sp_pro40		  --
--- Modificado por Armando Moreno 19/01/2002; -- la parte de los tipo de contratos
------------------------------------------------
--execute procedure sp_pr860bk('001','001','2012-07','2012-09',"*","*","*","*","001,003,006,008,010,011,012,013,014,021,022;","*","2012,2011,2010,2009,2008;")

drop procedure sp_pr860bk3;
CREATE PROCEDURE sp_pr860bk3()
RETURNING DECIMAL(16,2),DECIMAL(16,2);
   BEGIN
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura, v_clase,_cod_ramo CHAR(03);
      DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
      DEFINE v_desc_cobertura	             CHAR(100);
      DEFINE v_filtros                       CHAR(255);
      DEFINE v_filtros2                      CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_prima                		 DEC(16,2);
      DEFINE v_prima1                		 DEC(16,2);
      DEFINE v_tipo_contrato                 SMALLINT;

	  define _porc_impuesto					 dec(16,2);
	  define _porc_comision					 dec(16,2);
	  define _cuenta						 char(25);
	  define _serie 						 smallint;
	  define _impuesto						 dec(16,2);
	  define _comision						 dec(16,2);
	  define _por_pagar						 dec(16,2);
	  define _siniestro						 dec(16,2);

	  DEFINE _cod_traspaso	 				 CHAR(5);
	  define _traspaso		 				 smallint;
	  define _tiene_comis_rea				 smallint;
	  define _cantidad						 smallint;
	  define _tipo_cont                      smallint;
	  	
	  define _porc_cont_partic 				 dec(5,2);
	  define _porc_cont_terr                 dec(5,2);
	  DEFINE _porc_comis_ase   				 DECIMAL(5,2);
	  define _monto_reas					 dec(16,2);
	  define v_prima_suscrita				 dec(16,2);
	  define _cod_coasegur	 				 char(3);
	  define _nombre_coas					 char(50);
	  define _nombre_cob					 char(50);
	  define _nombre_con					 char(50);
	  define _cod_subramo					 char(3);
	  define _cod_origen					 char(3);
	  define _prima_tot_ret                  dec(16,2);
	  define _prima_sus_tot					 dec(16,2);
	  define _prima_tot_ret_sum              dec(16,2);
	  define _prima_tot_sus_sum              dec(16,2);
	  define _no_cambio						 smallint;
	  define _no_unidad						 char(5);
      define v_prima_cobrada           		 DEC(16,2);
	  define _porc_partic_coas				 dec(7,4);
	  define _fecha						     date;
	  define _porc_partic_prima				 dec(9,6);
	  define _p_sus_tot						 DEC(16,2);
	  define _p_sus_tot_sum					 DEC(16,2);
	  DEFINE _ano,_ano2 				     SMALLINT;
	  define _tot_comision 					 dec(16,2);
	  define _tot_impuesto 					 dec(16,2);
	  define _tot_prima_neta				 dec(16,2);
	  DEFINE _tiene_comision				 SMALLINT;
	  define _p_c_partic					 dec(5,2);
	  define _p_c_partic_hay				 smallint;
	  define v_existe                        smallint;

	  define nivel,_nivel                    smallint;
	  define _xnivel                         char(3);
	  define v_prima70, v_prima30            decimal (16,2);
	  define _comision70, _comision30        decimal (16,2);
	  define _impuesto70, _impuesto30        decimal (16,2);
	  define _por_pagar70, _por_pagar30      decimal (16,2);
	  define _siniestro70, _siniestro30      decimal (16,2);
	  define v_prima10,_por_pagar10 		 decimal (16,2);
	  define _comision10,_impuesto10		 decimal (16,2);
	  define _siniestro2,_sini_bk,_sini_dif  decimal (16,2);
	  define _siniestro3					 decimal (16,2);
	  define _pagado_neto					 decimal (16,2);
	  define _porc_impuesto4				 dec(7,4);
	  define _porc_comision4,_porc_comisiond dec(7,4);

	  DEFINE _anio_reas						 char(9);
	  DEFINE _trim_reas,_contrato_xl		 Smallint;
	  DEFINE _borderaux						 char(2);
	  DEFINE _bouquet						 smallint;
	  DEFINE _no_documento					 char(20);
	  DEFINE _flag , _cnt,_cnt2,_cnt3		 smallint;
	  DEFINE _serie1 			             smallint;
	  DEFINE _dt_vig_inic                    date;
	  define _facilidad_car,_tipo2           smallint;
	  define _cod_c                          char(5);
	  define _porc_terr,_porc_inun,_siniestro4           decimal (16,2);
	  define _no_reclamo                     char(10);

     SET ISOLATION TO DIRTY READ;


--evento inundacion para tomar la participacion de la swiss re

let _cnt2       = 0;
let _siniestro3 = 0;
let _siniestro4 = 0;

foreach

	SELECT t.no_reclamo,t.pagado_neto,t.cod_ramo
	  INTO _no_reclamo,_pagado_neto,_cod_ramo
	  FROM tmp_sinis t, reacomae r
	 where r.cod_contrato = t.cod_contrato
	   and t.seleccionado = 1
	   and t.tipo_contrato not in ('3','1')
	   and r.serie >= 2012
	   and t.cod_ramo in('001','003')

	select count(*)
	  into _cnt3
	  from recrccob
	 where no_reclamo = _no_reclamo
	   and cod_cobertura in('00010','00013','00036','00057','00058',
	                        '00059','00068','00089','00097','00125',
	                        '00160','00179','00182','00725','00726',
	                        '00732','00742','00743','00748','00754',
	                        '00781','00785','00790','00793','00855',
	                        '00878','00024');


	if _cnt3 > 0 then
		let _cnt2 = 1;

		if _cod_ramo = '001' then
			let _siniestro3 = _siniestro3 + _pagado_neto;
		else
			let _siniestro4 = _siniestro4 + _pagado_neto;
		end if

	end if

end foreach

return _siniestro3,_siniestro4;

END

END PROCEDURE 