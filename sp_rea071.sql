-- Reporte que analiza todo el registro contable y genera solo los errores.
-- 
-- Creado     : 29/01/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado :	29/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--Drop Procedure sp_rea071;		

Create Procedure "informix".sp_rea071()
RETURNING INTEGER, CHAR(200);

Define _no_tranrec        	CHAR(10); 
Define _no_reclamo        	CHAR(10); 
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

define _suma				dec(16,2);
define _cod_traspaso	 	char(5);
define _traspaso   		 	smallint;

Define _error_cod		  	INTEGER;
Define _error_isam		  	INTEGER;
Define _error_desc		  	CHAR(200);

--set debug file to "sp_sac58.trc";
--trace on;

Set Isolation To Dirty Read;

let _contador = 0;

begin 
on exception set _error_cod, _error_isam, _error_desc
	Return _error_cod, _error_cod || " " || trim(_error_desc) with resume;					  
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
  Where actualizado  = 1
	and sac_asientos = 0
	and numrecla[1,2] in('02','20','23')
--	and no_tranrec   = "1508443"
  order by numrecla[1,2]

	let _contador = _contador + 1;

	 select sum(monto)
	   into _monto2
	   from rectrcob
	  where no_tranrec = _no_tranrec;

	if _monto <> _monto2 then
		Let _error_cod  = 1;
		Let _error_desc = "Para la Transaccion  " || _transaccion || " " || _no_tranrec || "  La suma de montos no es igual  " || _monto || "  " || _monto2;
		Return _error_cod, _error_desc with resume;					  
	end if

	foreach
	 select cod_cobertura
	   into _cod_cobertura
	   from rectrcob
	  where no_tranrec = _no_tranrec 
   
		select cod_cober_reas
		  into _cod_cober_reas
		  from prdcober
		 where cod_cobertura = _cod_cobertura;

		select count(*)
		  into _cantidad
		  from rectrrea
		 where no_tranrec     = _no_tranrec
		   and cod_cober_reas = _cod_cober_reas;

		if _cantidad = 0 then

--			select count(*)
--			  into _cantidad
--			  from rectrrea
--			 where no_tranrec = _no_tranrec;

--			if _cantidad = 1 then

--				select cod_cober_reas
--				  into _cod_cober_reas
--				  from rectrrea
--				 where no_tranrec = _no_tranrec;

--			else
			
				{
				select count(*)
				  into _cantidad
				  from deivid_tmp:tmp_depurar26612
				 where transaccion_anula = _transaccion;
				 
				if _cantidad is null then
					let _cantidad = 0;
				end if
				
				if _cantidad <> 0 then
					
					insert into rectrrea
					select no_tranrec, 1, cod_contrato, porc_partic_suma, porc_partic_prima, tipo_contrato, 1, _cod_cober_reas
					  from rectrrea
					 where no_tranrec = _no_tranrec; 
				
				end if
				}
				
				return 1, "No hay Distribucion de Reaseguro para la Transaccion: " || _no_tranrec || " " || _cod_cober_reas with resume;

--			end if

		end if

		Foreach
		 Select cod_contrato
		   Into _cod_contrato
		   From rectrrea
		  Where no_tranrec     = _no_tranrec
		    and cod_cober_reas = _cod_cober_reas

			Select tipo_contrato,
			       nombre,
				   serie,
				   cod_traspaso
			  Into _tipo_contrato,
			       _desc_cont,
				   _serie,
				   _cod_traspaso
			  From reacomae
			 Where cod_contrato = _cod_contrato;

			If _tipo_contrato in (1,3) Then
				continue foreach;
			end if

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

				Let _error_cod  = 1;
				Let _error_desc = "Para la Transaccion " || _transaccion || " " || "Para el Contrato " || _cod_contrato || " Serie " || _serie   || " No Existe Contrato " || _cod_cober_reas || " " || trim(_desc_cont)  || " - " || trim(_desc_cob);
				Return _error_cod, _error_desc with resume;					  

--				insert into reacocob
--				values (_cod_contrato, _cod_cober_reas, 0.00, 0.00, 0.00, 0, 0.00, 0.00, "", 1, null, 0);

			End If

			select traspaso
			  Into _traspaso
			  From reacocob
			 Where cod_contrato   = _cod_contrato
			   And cod_cober_reas = _cod_cober_reas;

			if _traspaso = 1 then
				let _cod_contrato = _cod_traspaso;
			end if

			-- Evalua los contratos para el reaseguro cedido
			
			select count(*)
			  into _cantidad
			  from reacoase
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			if _cantidad = 0 then

				Let _error_cod  = 1;
				Let _error_desc = "Para la Transaccion " || _transaccion || " " || "Para el Contrato " || _cod_contrato || " Serie " || _serie   || " No Existen Companias para el Reas. x Pagar " || _cod_cober_reas || " " || trim(_desc_cont)  || " - " || trim(_desc_cob);
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

		End Foreach

	End Foreach

End Foreach;

end 

Let _error_cod  = 0;
let _error_desc = "Proceso Completado, " || _contador || " Registros Procesados ...";	

Return _error_cod, _error_desc with resume;					  

end procedure;