-- Reporte que analiza todo el registro contable y genera solo los errores.
-- 
-- Creado    : 07/01/2003 - Autor: Marquelda Valdelamar
-- Modificado: 24/04/2007 - Autor: Demetrio Hurtado Almanza
--                        - Cambios para el cambio del mayor general online diario
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac57;		

create procedure sp_sac57()
returning integer, char(200);
		  	
define _no_poliza        	char(10); 
define _no_endoso      	char(5);

define _cod_contrato	 	char(5);
define _cod_cober_reas   	char(3);
define _tipo_contrato    	smallint;
define _factor_impuesto	dec(5,2);
define _porc_comis_agt	dec(5,2);
define _cantidad		 	integer;
define _cuenta_cat       	char(25);   
define _cod_coasegur     	char(3);

define _contador		 	integer;
define _cod_ramo		 	char(3);
define _imp_gob 		 	smallint;
define _serie   		 	smallint;
define _desc_cont		 	char(50);
define _desc_cob         	char(50);
define _tiene_comision	smallint;
define _null			 	char(1);
define _suma			 	dec(16,2);

define _pbs_endoso		 	dec(16,2);
define _pbs_historico	 	dec(16,2);
define _pbs_emifacon	 	dec(16,2);
define _no_factura		 	char(10);
define _cod_endomov		char(3);

define _traspaso		 	smallint;
define _cod_traspaso	 	char(5);
define _no_unidad      	char(5);

define _error_cod		 	integer;
define _error_isam		 	integer;
define _error_desc		 	char(200);
define _periodo				char(7);

--Set Debug File To "sp_sac57.trc";
--trace on;

set Isolation To Dirty Read;

let _contador = 0.00;
let _null     = null;

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

select periodo_verifica
  into _periodo
  from emirepar;

Foreach
 Select no_poliza,
   	    no_endoso,
		prima_suscrita,
		no_factura,
		cod_endomov
   Into _no_poliza,
		_no_endoso,
		_pbs_endoso,
		_no_factura,
		_cod_endomov
   From endedmae
  Where actualizado  = 1
    and sac_asientos = 0
	and periodo      = _periodo
  order by no_documento[1,2]

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
	   
	if _pbs_emifacon is null then
		let _pbs_emifacon = 0;
	end if

	if _cod_endomov = "017" and
	   _pbs_endoso	 <> 0 	 then 	
	   
			Let _error_cod  = 1;
			Let _error_desc = "Para la Factura " || _no_factura || " Prima Suscrita Debe Ser 0 " ;
			Return _error_cod, _error_desc with resume;					  

	end if
			
--	if _no_factura <> "01-1380886" then 

	if _cod_endomov <> "017" then
	
		if abs(_pbs_endoso - _pbs_emifacon) > 0.01 then

			Let _error_cod  = 1;
			Let _error_desc = "Para la Factura " || _no_factura || " Hay Diferencias en la PBS de Reaseguro" ;
			Return _error_cod, _error_desc with resume;					  
		
		end if

	end if

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select imp_gob
	  into _imp_gob
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let _contador = _contador + 1;

	-- Verificacion del Reaseguro

	foreach
	  select no_unidad
	    into _no_unidad
	    from endeduni
	   where no_poliza = _no_poliza
	     and no_endoso = _no_endoso
	   order by no_unidad

	  SELECT count(*)
	    INTO _cantidad
	    FROM emifacon
	   WHERE no_poliza = _no_poliza
	     AND no_endoso = _no_endoso
		 AND no_unidad = _no_unidad;

		if _cantidad   = 0     and 
		   _pbs_endoso <> 0.00 then

			call sp_pro338(_no_poliza, _no_endoso, _no_unidad) returning _error_cod, _error_desc;

			if _error_cod <> 0 then
				Return _error_cod, _error_desc with resume;					  
			end if

			Let _error_cod  = 1;
			Let _error_desc = "Para la Factura: " || _no_factura || " No Poliza: " || _no_poliza || " Endoso: " || _no_endoso || " No Existe Unidad: " || _no_unidad;
			Return _error_cod, _error_desc with resume;					  

		end if

	end foreach

	-- Verificacion para los Contratos de Reaseguro

	Foreach
	 Select cod_contrato,
			cod_cober_reas
	   Into _cod_contrato,
			_cod_cober_reas
	   From emifacon
	  Where no_poliza = _no_poliza
	    And no_endoso = _no_endoso

		Select tipo_contrato,
		       serie,
			   nombre,
			   cod_traspaso
		  Into _tipo_contrato,
		       _serie,
			   _desc_cont,
			   _cod_traspaso
		  From reacomae
		 Where cod_contrato = _cod_contrato;

		-- No Evalua el Contrato de Retencion
		
		If _tipo_contrato = 1 Then
			Continue Foreach;
		End If

		Select Count(*)
		  Into _cantidad
		  From reacocob
		 Where cod_contrato   = _cod_contrato
		   And cod_cober_reas = _cod_cober_reas;

		Select nombre
		  into _desc_cob
		  from reacobre
		 where cod_cober_reas = _cod_cober_reas;

		-- Si no existe la cobertura a evaluar la crea con valores por default

		If _cantidad is null Then
			let _cantidad = 0;
		end if

		If _cantidad = 0 Then
			insert into reacocob
			values (_cod_contrato, _cod_cober_reas, 0.00, 0.00, 0.00, 0, 0.00, 0.00, "", 1, _null, 0, 0, 0, null, 0, 0, null);
		End If

		let _cuenta_cat = "";

		Select porc_impuesto,
		       porc_comision,
			   cuenta,
			   tiene_comision,
			   cod_coasegur,
			   traspaso
		  Into _factor_impuesto,
			   _porc_comis_agt,
			   _cuenta_cat,
			   _tiene_comision,
			   _cod_coasegur,
			   _traspaso
		  From reacocob
		 Where cod_contrato   = _cod_contrato
		   And cod_cober_reas = _cod_cober_reas;

		if _tipo_contrato not in (1, 3) then

			if _traspaso = 1 then

				let _cod_contrato = _cod_traspaso;
				
				select porc_impuesto,
				       porc_comision,
					   cuenta,
					   tiene_comision,
					   cod_coasegur,
					   traspaso
				  into _factor_impuesto,
					   _porc_comis_agt,
					   _cuenta_cat,
					   _tiene_comision,
					   _cod_coasegur,
					   _traspaso
				  From reacocob
				 Where cod_contrato   = _cod_contrato
				   And cod_cober_reas = _cod_cober_reas;

			end if

			select count(*)
			  into _cantidad
			  from reacoase
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			if _cantidad = 0 then

				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  No Existen Companias para el Reas. x Pagar " || _cod_cober_reas || "   " || trim(_desc_cont)  || " - " || trim(_desc_cob) || " " || _no_poliza || " " || _no_endoso;
				Return _error_cod, _error_desc with resume;					  

			end if

			select sum(porc_cont_partic)
			  into _suma
			  from reacoase
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			if _suma <> 100 then

				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  La Suma de Companias para el Reas. x Pagar No es 100% " || _cod_cober_reas || "   " || trim(_desc_cont)  || " - " || trim(_desc_cob);
				Return _error_cod, _error_desc with resume;					  

			end if

		end if
{
		If _cuenta_cat is null or
		   _cuenta_cat = ""    Then
			Let _error_cod  = 1;
			Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  No Existe Cuenta de Reaseguro x Pagar para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont)  || " - " || trim(_desc_cob);
			Return _error_cod, _error_desc with resume;					  
		End If
}

		-- Para los frontins verifica la compania del fronting

{
		If _tipo_contrato = 2 Then
			
			if _cod_coasegur is null then
				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  Es Necesaria la Compania del Fronting para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont) || " - " || trim(_desc_cob);
				Return _error_cod, _error_desc with resume;
			end if

		End If
}
		-- Para los Facultativos NO Verifica los Impuestos ni la Comision

		If _tipo_contrato = 3 Then
			Continue Foreach;
		End If

		-- El Ramo de Fianzas no debe Tener Impuestos del Gobierno

		If _imp_gob = 0 Then

			If _factor_impuesto <> 0.00 Then
				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato " || _no_poliza || " " || _cod_contrato || "  Serie  " || _serie   || "  El Porcentaje de Impuesto Debe Ser 0.00 para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont) || " - " || trim(_desc_cob);
				Return _error_cod, _error_desc with resume;
			End If

		Else

			If _factor_impuesto = 0.00 Then
				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato " || _no_poliza || " " || _cod_contrato || "  Serie  " || _serie   || "  El Porcentaje de Impuesto es 0.00 para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont) || " - " || trim(_desc_cob);
				Return _error_cod, _error_desc with resume;
			End If
		
		End If

		If _tiene_comision = 1 Then

			If _porc_comis_agt = 0.00 Then
				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  El Porcentaje de Comision es 0.00 para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont) || " - " || trim(_desc_cob);
				Return _error_cod, _error_desc with resume;
			End If

		Else

			If _porc_comis_agt <> 0.00 Then
				Let _error_cod  = 1;
				Let _error_desc = "Factura " || _no_factura || " Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  El Porcentaje de Comision Debe Ser 0.00 para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont) || " - " || trim(_desc_cob);
				Return _error_cod, _error_desc with resume;
			End If

		End If

	end foreach

End Foreach;

end

let _error_cod  = 0;
let _error_desc = "Proceso Completado, " || _contador || " Registros Procesados ...";	

return _error_cod, _error_desc;

End Procedure;
