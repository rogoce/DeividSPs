-- Procedimiento actualizar la cobertura de reaseguro 031 Automovil casco,
-- que tienen la cobertura 002 Automovil.
-- 
-- Creado    : 03/09/2013 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis109c;		

Create Procedure "informix".sp_sis109c()
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

update prdcober
   set cod_cober_reas = '031'
 where cod_ramo = '002'
   and cod_cobertura in('00903','00121','00606','00118','00900','00120','00902','01146','01233','00103','00901','00904');


end

let _error_cod  = 0;
let _error_desc = "Proceso Completado.";	

return _error_cod, _error_desc;

End Procedure;
