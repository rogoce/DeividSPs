-- Reporte que analiza todo el registro contable y genera solo los errores.
-- 
-- Creado    : 07/01/2003 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

Drop Procedure sp_par63;		

Create Procedure "informix".sp_par63(a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING INTEGER, CHAR(200);
		  	
define _no_poliza        CHAR(10); 
define _no_endoso        CHAR(5);

DEFINE _cod_contrato	 CHAR(5);
DEFINE _cod_cober_reas   CHAR(3);
DEFINE _tipo_contrato    SMALLINT;
DEFINE _factor_impuesto	 DEC(5,2);
DEFINE _porc_comis_agt	 DEC(5,2);
DEFINE _cantidad		 INTEGER;
DEFINE _cuenta_cat       CHAR(25);   
DEFINE _cod_coasegur     CHAR(3);

define _error_cod		 INTEGER;
define _error_isam		 INTEGER;
define _error_desc		 CHAR(200);
DEFINE _contador		 INTEGER;
define _cod_ramo		 char(3);
define _imp_gob 		 smallint;
define _serie   		 smallint;
define _desc_cont		 char(50);
define _desc_cob         char(50);
define _tiene_comision	 smallint;
define _null			 char(1);

--set debug file to "sp_par63.trc";

Set Isolation To Dirty Read;

let _contador = 0.00;
let _null     = null;

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

Foreach
 Select no_poliza,
   	    no_endoso
   Into _no_poliza,
		_no_endoso
   From endedmae
  Where actualizado = 1
    And periodo    >= a_periodo1
    And periodo    <= a_periodo2

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select imp_gob
	  into _imp_gob
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let _contador = _contador + 1;

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
			   nombre
		  Into _tipo_contrato,
		       _serie,
			   _desc_cont
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
			values (_cod_contrato, _cod_cober_reas, 0.00, 0.00, 0.00, 0, 0.00, 0.00, "", 1, _null);
		End If

		let _cuenta_cat = "";

		Select porc_impuesto,
		       porc_comision,
			   cuenta,
			   tiene_comision,
			   cod_coasegur
		  Into _factor_impuesto,
			   _porc_comis_agt,
			   _cuenta_cat,
			   _tiene_comision,
			   _cod_coasegur
		  From reacocob
		 Where cod_contrato   = _cod_contrato
		   And cod_cober_reas = _cod_cober_reas;

		If _cuenta_cat is null or
		   _cuenta_cat = ""    Then
			Let _error_cod  = 1;
			Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  No Existe Cuenta de Reaseguro x Pagar para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont)  || " - " || trim(_desc_cob);
			Return _error_cod, _error_desc with resume;					  
		End If

		-- Para los frontins verifica la compania del fronting

		If _tipo_contrato = 2 Then
			
			if _cod_coasegur is null then
				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  Es Necesaria la Compania del Fronting para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont) || " - " || trim(_desc_cob);
				Return _error_cod, _error_desc with resume;
			end if

		End If

		-- Para los Facultativos NO Verifica los Impuestos ni la Comision

		If _tipo_contrato = 3 Then
			Continue Foreach;
		End If

		-- El Ramo de Fianzas no debe Tener Impuestos del Gobierno

		If _imp_gob = 0 Then

			If _factor_impuesto <> 0.00 Then
				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  El Porcentaje de Impuesto Debe Ser 0.00 para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont) || " - " || trim(_desc_cob);
				Return _error_cod, _error_desc with resume;
			End If

		Else

			If _factor_impuesto = 0.00 Then
				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  El Porcentaje de Impuesto es 0.00 para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont) || " - " || trim(_desc_cob);
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
				Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  El Porcentaje de Comision Debe Ser 0.00 para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont) || " - " || trim(_desc_cob);
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
