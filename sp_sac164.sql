-- Reporte que analiza todo el registro contable y genera solo los errores.
-- 
-- Creado    : 07/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac164;		
create procedure sp_sac164()
returning integer, char(200);
		  	
define _error_desc			varchar(200);
define _desc_cont			char(50);
define _desc_cob			char(50);
define _cuenta_cat			char(25);   
define _no_factura			char(10);
define _no_remesa			char(10); 
define _no_poliza			char(10); 
define _periodo				char(7);
define _cod_traspaso		char(5);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _cod_ramo			char(3);
define _null				char(1);
define _factor_impuesto		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _porc_partic_prima	dec(9,6);
define _pbs_historico		dec(16,2);
define _pbs_emifacon		dec(16,2);
define _pbs_endoso			dec(16,2);
define _suma				dec(16,2);
define _tipo_contrato		smallint;
define _tiene_comision		smallint;
define _traspaso			smallint;
define _imp_gob				smallint;
define _serie				smallint;
define _error_isam			integer;
define _error_cod			integer;
define _cantidad			integer;
define _contador			integer;
define _renglon				integer;

set isolation to dirty read;

let _contador = 0.00;
let _null = null;

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

-- Facturas
select periodo_verifica
  into _periodo
  from emirepar;
  
foreach
	select no_poliza,
		   no_endoso
	  into _no_poliza,
		   _no_endoso
	  from sac999:reacomp
	 where tipo_registro = 1
	   and sac_asientos  = 0
	   and periodo = _periodo

	select no_poliza,
		   no_endoso,
		   prima_suscrita,
		   no_factura
	 into _no_poliza,
	      _no_endoso,
	      _pbs_endoso,
	      _no_factura
	 from endedmae
    where no_poliza = _no_poliza
	  and no_endoso = _no_endoso;

	select prima_suscrita
	  into _pbs_historico
	  from endedhis
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _pbs_endoso is null then
		let _pbs_endoso = 0;
	end if

	if _pbs_historico is null then
		let _pbs_historico = 0;
	end if

	if _pbs_endoso <> _pbs_historico then

		Let _error_cod  = 1;
		Let _error_desc = "Para la Factura " || _no_factura || " Hay Diferencias en la PBS " ;
		Return _error_cod, _error_desc with resume;					  
	
	end if

	select sum(prima)
	  into _pbs_emifacon	 	
	  from emifacon
	 where no_poliza = _no_poliza
       and no_endoso = _no_endoso;

    if _no_factura not in("01-2505140","09-510072","09-510460","03-225482") then
		if abs(_pbs_endoso - _pbs_emifacon) > 0.01 then

			Let _error_cod  = 1;
			Let _error_desc = "Para la Factura " || _no_factura || " Hay Diferencias en la PBS de Reaseguro" ;
			Return _error_cod, _error_desc with resume;
	   end if
    end if

	-- Verificacion del Reaseguro
	foreach
		select no_unidad
		  into _no_unidad
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		 order by no_unidad

		select count(*)
		  into _cantidad
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;

		if _cantidad   = 0 and _pbs_endoso <> 0.00 then

			call sp_pro338(_no_poliza, _no_endoso, _no_unidad) returning _error_cod, _error_desc;

			if _error_cod <> 0 then
				return _error_cod, _error_desc with resume;					  
			end if

			let _error_cod  = 1;
			let _error_desc = "Para la Factura: " || _no_factura || "No Poliza: " || _no_poliza || " Endoso: " || _no_endoso || " No Existe Unidad: " || _no_unidad;
			return _error_cod, _error_desc with resume;
		end if
	end foreach
end foreach;

-- Verificacion de Cheques de Devolucion de Primas (Pagados/Anulados)

foreach
	select no_poliza,
		   no_remesa
	  into _no_poliza,
		   _no_remesa
	  from sac999:reacomp
	 where tipo_registro in (4,5)
	   and sac_asientos = 0
	   and periodo = _periodo

	foreach
		select porc_proporcion
		  into _porc_comis_agt
		  from chqreaco
		 where no_requis = _no_remesa
		   and no_poliza = _no_poliza

		if _porc_comis_agt = 0.00 then

			let _error_cod  = 1;
			let _error_desc = "Para la Requisicion " || _no_remesa || " % Proporcion es 0" ;
			return _error_cod, _error_desc with resume;
		end if
	end foreach
end foreach;

foreach
	select no_remesa,
		   renglon
	  into _no_remesa,
		   _renglon
	  from sac999:reacomp
	 where tipo_registro in (2)
	   and sac_asientos = 0
	   and periodo = _periodo
	   
	select no_poliza into _no_poliza from cobredet
	where no_remesa = _no_remesa
	  and renglon = _renglon;

	select cod_ramo into _cod_ramo from emipomae
	where no_poliza = _no_poliza
	  and actualizado = 1;
	
	if _cod_ramo in('002','023','020') then
		exit foreach;
	end if
	   
	select sum(porc_proporcion * porc_partic_prima / 100)
	  into _porc_partic_prima
      from cobreaco
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _porc_partic_prima is null then
		let _porc_partic_prima = 0;
	end if

	if _porc_partic_prima <> 100.00 then
		return 1, "% Proporcion No Suma 100% Remesa: " || _no_remesa || "  " || _renglon || " " with resume;
	end if
end foreach
end

let _error_cod  = 0;
let _error_desc = "Proceso Completado, " || _contador || " Registros Procesados ...";	

return _error_cod, _error_desc;

end procedure;