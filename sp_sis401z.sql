--****************************************************************
-- Procedimiento que crea el reaseguro para una renovacion manual especial
--****************************************************************

-- Creado    : 12/12/2012 - Autor: Armando Moreno M.
-- Modificado: 12/12/2012 - Autor: Armando Moreno M.

drop procedure sp_sis401z;

create procedure "informix".sp_sis401z() 
RETURNING char(20),smallint,char(10),smallint;

--- Actualizacion de Polizas

DEFINE r_anos          smallint;
DEFINE _porc_depre     DEC(5,2);
DEFINE _porc_depre_uni DEC(5,2);
DEFINE _porc_depre_pol DEC(5,2);
DEFINE _no_unidad      CHAR(5); 
DEFINE _cod_cobertura  CHAR(5); 
DEFINE _cod_producto   CHAR(5); 
DEFINE _valor_asignar  CHAR(1); 
DEFINE _cant_unidades  INTEGER; 
DEFINE _suma_asegurada INTEGER;
DEFINE _no_motor       CHAR(30);
DEFINE _suma_decimal   DEC(16,2);
DEFINE _suma_difer	   DEC(16,2);
DEFINE _vigencia_final DATE;
DEFINE li_dia		   SMALLINT;
DEFINE li_mes		   SMALLINT;
DEFINE li_ano		   SMALLINT;
DEFINE ld_fecha_1_pago DATE;
DEFINE li_no_pagos	   SMALLINT;
DEFINE ls_cod_perpago  CHAR(3);
DEFINE li_meses		   SMALLINT;
define _saldo_unidad   smallint;
define _porc_com       DEC(5,2);
define _cod_agt        char(5);
define _cod_rammo      char(3);
define _cod_ramo       char(3);
define _ramo_sis       smallint;
define _nounidad       char(5);
define _valor          integer;
define _error          integer;
define _serie          integer;
define _cod_ruta       char(5);
define _orden          integer;
define _cod_contrato   char(5);
define _porc_prima     DEC(10,4);
define _porc_suma      DEC(10,4);
define _cod_cober_reas char(3);
define _tipo_contrato  char(1);
DEFINE _suma           DEC(16,2);
define _no_cambio      smallint;
define _cod_prod       char(5);
define _r_anos         smallint;
define _cod_subramo    char(3);
define _tipo_agente    char(1);
define _aplica_imp     smallint;
define _cod_impuesto   char(3);
define _cod_origen     char(3);
define _canti          smallint;
define _cod_cont_fac   char(5);
define _fronting       smallint;
define _fronting2	   smallint;
define _vig_ini		   date;
define _cod_grupo      char(5);
define _prima_bruta       dec(16,2);
define _cnt            smallint;
define _vig_fin        date;
define _no_documento   char(20);
define _mes            smallint;
define _anno           smallint;
define _no_poliza      char(10);
define _no_endoso      char(10);
define _no_pagos       smallint;
define _no_pagos_end   smallint;

--SET DEBUG FILE TO "sp_pro320c.trc"; 
--trace on;

BEGIN

let _prima_bruta = 0;


foreach

select no_documento
  into _no_documento
  from emipomae
 where no_documento[1,2] = '19'
   and actualizado = 1
   and estatus_poliza = 1
   group by no_documento
   
let _no_poliza = sp_sis21(_no_documento);

select no_pagos
  into _no_pagos
  from emipomae
 where no_poliza = _no_poliza;
 
 foreach
	select no_endoso,
	       no_pagos,
		   prima_bruta
	  into _no_endoso,
           _no_pagos_end,
		   _prima_bruta
	  from endedmae
	 where no_poliza = _no_poliza
	    
		if _no_pagos <> _no_pagos_end and _prima_bruta <> 0 then
       
			return _no_documento,_no_pagos,_no_endoso,_no_pagos_end with resume;
		end if	
	   
 end foreach
end foreach
END

end procedure;