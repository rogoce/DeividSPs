-- Reporte que analiza todo el registro contable y genera solo los errores.
-- 
-- Creado     : 29/01/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado :	29/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

Drop Procedure sp_par76;		

Create Procedure "informix".sp_par76(a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING INTEGER, CHAR(200);

Define _no_tranrec        	CHAR(10); 
Define _no_reclamo        	CHAR(10); 
Define _error_cod		  	INTEGER;
Define _error_desc		  	CHAR(200);
define _cod_cobertura		char(5);
define _cod_cober_reas		char(3);
define _cuenta_cat			char(25);
define _cod_contrato	 	char(5);
DEFINE _cantidad		 	INTEGER;
define _desc_cont		 	char(50);
define _desc_cob         	char(50);
define _serie   		 	smallint;
define _tipo_contrato       smallint;
define _monto				dec(16,2);
define _monto2				dec(16,2);
define _transaccion			char(10);
define _contador			integer;

--set debug file to "sp_par76.trc";

Set Isolation To Dirty Read;

let _contador = 0;

begin 
on exception set _error_cod
	Return _error_cod, "Error Interno de Programasion" with resume;					  
end exception

Foreach with hold
 Select no_tranrec,
        no_reclamo,
		monto,
		transaccion
   Into _no_tranrec,
        _no_reclamo,
		_monto,
		_transaccion
   From rectrmae
  Where actualizado = 1
    And periodo    >= a_periodo1
    And periodo    <= a_periodo2

	let _contador = _contador + 1;

--{
	 select sum(monto)
	   into _monto2
	   from rectrcob
	  where no_tranrec = _no_tranrec;

	if _monto <> _monto2 then
		Let _error_cod  = 1;
		Let _error_desc = "Para la Transaccion  " || _transaccion || " " || _no_tranrec || "  La suma de montos no es igual  " || _monto || "  " || _monto2;
		Return _error_cod, _error_desc with resume;					  
	end if
--}

	Foreach
	 Select cod_contrato
	   Into _cod_contrato
	   From rectrrea
	  Where no_tranrec = _no_tranrec

		Select tipo_contrato,
		       nombre,
			   serie
		  Into _tipo_contrato,
		       _desc_cont,
			   _serie
		  From reacomae
		 Where cod_contrato = _cod_contrato;

		If _tipo_contrato = 1 Then
			continue foreach;
		end if

--trace _no_reclamo || " " || _tipo_contrato;

		foreach
		 select cod_cobertura
		   into _cod_cobertura
		   from rectrcob
		  where no_tranrec = _no_tranrec 
	   
			select cod_cober_reas
			  into _cod_cober_reas
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

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

			If _cantidad = 0 Then
				insert into reacocob
				values (_cod_contrato, _cod_cober_reas, 0.00, 0.00, 0.00, 0, 0.00, 0.00, "", 1, null);
			End If

			Select cuenta
			  Into _cuenta_cat
			  From reacocob
			 Where cod_contrato   = _cod_contrato
			   And cod_cober_reas = _cod_cober_reas;

			If _cuenta_cat is null or
			   _cuenta_cat = ""    Then

				if _tipo_contrato = 3 Then
 
					update reacocob
					   set cuenta         = "231-03"
					 Where cod_contrato   = _cod_contrato
					   And cod_cober_reas = _cod_cober_reas;

				end if

				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato  " || _cod_contrato || "  Serie  " || _serie   || "  No Existe Cuenta de Reaseguro x Pagar para la Cobertura  " || _cod_cober_reas || "   " || trim(_desc_cont)  || " - " || trim(_desc_cob);
				Return _error_cod, _error_desc with resume;					  
			End If

		End Foreach

	End Foreach

End Foreach;

end 

Let _error_cod  = 0;
let _error_desc = "Proceso Completado, " || _contador || " Registros Procesados ...";	

Return _error_cod, _error_desc with resume;					  

end procedure;