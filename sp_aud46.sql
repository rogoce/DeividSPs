-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud46;		

create procedure "informix".sp_aud46() 
returning char(20), dec(16,2), dec(16,2), dec(16,2), dec(16,2), dec(16,2), char(3), char(3); 

define _no_poliza           char(10);
define _no_documento        char(20);
define _cntcol				smallint;
define _prima_col_ori		dec(16,2);
define _prima_otro_ori		dec(16,2);
define _prima_col_sim		dec(16,2);
define _no_unidad           char(5);
define _suma_asegurada		dec(16,2);
define _no_motor            char(30);
define _ano_auto            integer;
define _anos                smallint;
define _valor				dec(16,2);
define _cod_producto		char(5);
define li_acepta_desc		integer;
define ld_descuento			dec(16,2);
define ld_prima_resta		dec(16,2);
define ld_recargo			dec(16,2);
define _cod_cobertura       char(5);
define _uso_auto            char(1);
define _cod_ramo, _cod_subramo char(3);
define _prima_neta          dec(16,2);

define _error_cod  			integer;
define _error_desc          varchar(50);
define _error_isam	        integer;

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	return trim(_error_desc) || " " || _no_documento, null, null, null, null, null, null, null;
end exception

--SET DEBUG FILE TO "sp_aud46.trc";
--trace on;


foreach
	 select no_poliza, no_documento, cod_ramo, cod_subramo
	   into _no_poliza, _no_documento, _cod_ramo, _cod_subramo
	   from	emipomae
	  where periodo >= '2013-01'
	    and periodo <= '2013-12'
	    and actualizado   = 1
		and cod_ramo = '002' 
		and cod_subramo in ('001','012')
	  order by no_poliza

     let _prima_col_ori = 0;
     let _prima_otro_ori = 0;

	 select sum(prima_neta)
	   into _prima_col_ori	            --> Prima colision total
	   from emipocob
	  where no_poliza =	_no_poliza
	    and cod_cobertura in ('00119','00121');

	 select sum(prima_neta)
	   into _prima_otro_ori
	   from emipocob
	  where no_poliza =	_no_poliza
	    and cod_cobertura not in ('00119','00121');	 --> Prima otros total

     if _prima_col_ori is null then
     	let _prima_col_ori = 0;
	 end if
     if _prima_otro_ori is null then
     	let _prima_otro_ori = 0;
	 end if

     let _prima_col_sim = 0;
	 let _prima_neta = 0;

     foreach
		select no_unidad, suma_asegurada, cod_producto
		  into _no_unidad, _suma_asegurada, _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza

		select no_motor, uso_auto
		  into _no_motor, _uso_auto
		  from emiauto
		 where no_poliza = _no_poliza  
		   and no_unidad = _no_unidad;

	     let _cntcol = 0;

	     select	count(*)
		   into _cntcol
		   from emipocob
		  where no_poliza =	_no_poliza
		    and no_unidad = _no_unidad
		    and cod_cobertura in ('00119','00121');

	     if _cntcol = 0 then	--_prima_otro_ori = 0 or or _prima_col_ori = 0  or _uso_auto <> "P" 

		  {   select	a.prima_neta
			   into _prima_neta
			   from emipocob a, prdcobpd b
			  where a.cod_cobertura = b.cod_cobertura
			    and b.cod_producto  = _cod_producto
			    and a.no_poliza =	_no_poliza
			    and a.no_unidad = _no_unidad
			    and a.cod_cobertura in ('00119','00121');

            if _prima_neta is null then
				let _prima_neta = 0;
			end if

			let _prima_col_sim = _prima_col_sim + _prima_neta;
			}
			continue foreach;
		 end if

	     select	a.cod_cobertura
		   into _cod_cobertura
		   from emipocob a, prdcobpd b
		  where a.cod_cobertura = b.cod_cobertura
		    and b.cod_producto  = _cod_producto
		    and a.no_poliza =	_no_poliza
		    and a.no_unidad = _no_unidad
		    and a.cod_cobertura in ('00119','00121');

        if _suma_asegurada is null then
			let _suma_asegurada = 0.00;
		end if
		 

        select ano_auto
          into _ano_auto
          from emivehic
         where no_motor = _no_motor;

        if _ano_auto is null then
			let _ano_auto = 0;
		end if
         
        let _anos = 2013 - _ano_auto;

        if _anos < 0 then
        	let _anos = 0;
        end if

        let _anos = _anos + 1;
        
        select valor
          into _valor 
          from prdtasec
         where cod_producto = '01871'
           and cod_cobertura = '00119'
           and renglon = _anos;
           
        let _prima_neta = _valor * _suma_asegurada / 100;

        if _prima_neta is null then
			let _prima_neta = 0;
		end if


		SELECT acepta_desc
		  INTO li_acepta_desc
		  FROM prdcobpd
		 WHERE cod_producto  = _cod_producto
		   AND cod_cobertura = _cod_cobertura;

	    -- Buscar Descuento
		LET ld_descuento = 0.00;
		LET ld_prima_resta = 0.00;
		If li_acepta_desc = 1 Then
		   CALL sp_proe21(_no_poliza, _no_unidad, _prima_neta) RETURNING ld_descuento;
		End If

		If ld_descuento > 0 Then
		   LET ld_prima_resta = _prima_neta - ld_descuento;
		End If

		-- Buscar Recargo
		LET ld_recargo = 0.00;
		If li_acepta_desc = 1 Then
		   CALL sp_proe22(_no_poliza, _no_unidad, ld_prima_resta) RETURNING ld_recargo;
		End If

		-- Calcular Prima Neta
		LET _prima_neta = _prima_neta + ld_recargo - ld_descuento;
		LET _prima_col_sim = _prima_col_sim + _prima_neta;
     end foreach

     return _no_documento, _prima_otro_ori, _prima_col_ori, _prima_col_ori + _prima_otro_ori, _prima_col_sim, _prima_col_sim + _prima_otro_ori, _cod_ramo, _cod_subramo with resume; 

end foreach

end
end procedure

