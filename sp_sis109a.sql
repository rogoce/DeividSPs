-- Procedimiento para insertar en lote la cobertura 031 Automovil Casco a las coberturas de reaseguro para los contratos
-- que tienen la cobertura 002 Automovil.
-- 
-- Creado    : 03/09/2013 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis109a;		

Create Procedure "informix".sp_sis109a()
RETURNING INTEGER, CHAR(200);
		  	
define _no_endoso        CHAR(5);

DEFINE _cod_contrato	 CHAR(5);
DEFINE _cod_cober_reas   CHAR(3);
DEFINE _tipo_contrato    SMALLINT;
DEFINE _factor_impuesto	 DEC(5,2);
DEFINE _porc_comis_agt	 DEC(5,2);
DEFINE _cantidad		 INTEGER;
DEFINE _cuenta_cat       CHAR(25);   
DEFINE _cod_coasegur     CHAR(3);

define _error_cod,_cnt	 INTEGER;
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
define _suma			 dec(16,2);

define _pbs_endoso		 dec(16,2);
define _pbs_historico	 dec(16,2);
define _no_factura		 char(10);

define _traspaso		 smallint;
define _cod_traspaso	 char(5);
define _no_unidad        char(5);

Set Isolation To Dirty Read;

let _contador = 0.00;
let _null     = null;
let _no_endoso = '00000';

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

Foreach

 Select cod_contrato
   Into _cod_contrato
   From reacomae

   select count(*)
     into _cnt
	 from reacocob
	where cod_contrato   = _cod_contrato
	  and cod_cober_reas = '002';

   if _cnt > 0 then
       select count(*)
	     into _cnt
		 from reacocob
		where cod_contrato   = _cod_contrato
		  and cod_cober_reas = '031';

	  if _cnt = 0 then
			select * from reacocob
			 where cod_contrato   = _cod_contrato
		       and cod_cober_reas = '002'
		      into temp prueba;

			update prueba
			   set cod_cober_reas = '031';

			insert into reacocob
			select * 
			  from prueba;

			drop table prueba;

			let _tiene_comision = 0;

			select tiene_comision
			  into _tiene_comision
			  from reacocob
			 where cod_contrato   = _cod_contrato
		       and cod_cober_reas = '002';

			if _tiene_comision = 2 then	--Por reasegurador

				select * from reacoase
				 where cod_contrato   = _cod_contrato
			       and cod_cober_reas = '002'
			      into temp prueba;

				update prueba
				   set cod_cober_reas = '031';

				insert into reacoase
				select * 
				  from prueba;

				drop table prueba;

			end if
	  end if
   else
	continue foreach;
   end if

End Foreach;

end

let _error_cod  = 0;
let _error_desc = "Proceso Completado.";	

return _error_cod, _error_desc;

End Procedure;
