-- Listado de las polizas de salud individual   
-- Creado    : 21/03/2012 - Autor: Federico Coronado.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_web12;

CREATE PROCEDURE "informix".sp_web12(a_compania CHAR(3),a_sucursal CHAR(3),a_agente CHAR(10),a_ano integer, a_usuario CHAR(10), a_membrete SMALLINT DEFAULT 0)
RETURNING	CHAR(20),
			VARCHAR(50),
			char(10),
			VARCHAR(50),
			char(3),
			VARCHAR(50),
			char(3),
		    varCHAR(50),
			decimal(10,2),
			VARCHAR(200),
			SMALLINT;


DEFINE _no_poliza        	CHAR(10);
DEFINE _cod_contratante  	CHAR(10);
DEFINE _cod_pagador      	CHAR(10);
DEFINE _ramo_sis	     	SMALLINT;
DEFINE _cod_ramo	     	CHAR(3);
DEFINE _cod_producto         CHAR(10);
define _nombre_producto  	varchar(50);

define _concatena_depen	    varchar(100);

define _nombre_asegurado 	varchar(100);
define _nombre_ramo		 	varchar(50);
define _nombre_pagador   	varchar(100);
define _nombre_formapa		varchar(100);
define _nombre_perpago		varchar(100);

define _periodo				char(7);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _numrecla			char(20);
define _tipo_persona    	CHAR(1);
define _flag			 	smallint;
define _saber_cobro		 	smallint;
define _saber_reclamo	 	smallint;
define _sindato			 	smallint;
DEFINE _nueva_renov      	CHAR(1);

define _cod_perpago      	CHAR(3);
define _cod_formapag    	CHAR(3);

define _suma_deducible    	decimal(10,2);
define _deducible    	    decimal(10,2);

define _cedula          	varchar(30);
define _no_documento        CHAR(20);
define _cantidad			smallint;	
define _no_unidad2          CHAR(5);
define _agno                CHAR(4);

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo1;

let _agno = a_ano;
let _flag = 0;
let _saber_reclamo = 0;
let _saber_cobro   = 0;
let _sindato       = 0;
let _suma_deducible = 0;

-- SET DEBUG FILE TO "sp_web12.trc";      
-- TRACE ON;                                                                     


foreach	with hold
 select a.no_poliza,
        a.nueva_renov,
		a.cod_ramo,
		a.no_documento
   into _no_poliza,
        _nueva_renov,
		_cod_ramo,
		_no_documento
   from emipomae a, emipoagt b, prdramo c
  where a.no_poliza  = b.no_poliza
    and a.cod_ramo   = c.cod_ramo
    and b.cod_agente = a_agente
    and a.actualizado  = 1
	and c.ramo_sis     = 5

 select count(*)
   into _cantidad
   from emipouni
  where no_poliza = _no_poliza;

 if _cantidad = 1 then
		 let _flag = 1;
	 	 select cod_contratante,
				cod_perpago,
				cod_formapag
	 	   into _cod_pagador,
				_cod_perpago,
				_cod_formapag
		   from emipomae
		  where no_poliza = _no_poliza;

		 select nombre
		   into _nombre_pagador
		   from cliclien
		  where cod_cliente = _cod_pagador;

	     select cod_asegurado,
				cod_producto
		   into _cod_contratante,
				_cod_producto
		   from emipouni
		  where no_poliza = _no_poliza;

		 select nombre,
				cedula,
				tipo_persona
		   into _nombre_asegurado,
		        _cedula,
				_tipo_persona
		   from cliclien
		  where cod_cliente = _cod_contratante;

		 select nombre,
				ramo_sis
		   into _nombre_ramo,
				_ramo_sis
		   from prdramo
		  where cod_ramo = _cod_ramo;

		 select nombre
		 	   into _nombre_formapa
		 from cobforpa
		 where cod_formapag = _cod_formapag;

		 select nombre
		 	   into _nombre_perpago
		 from cobperpa
		 where cod_perpago = _cod_perpago;

		select nombre
		 	   into _nombre_producto
		 from prdprod
		 where cod_producto = _cod_producto;

	   let _suma_deducible = 0;
		   foreach	with hold
			 select deducible
			 	   into _deducible
			 	   from emipocob
			 where no_poliza = _no_poliza

			let _suma_deducible = _deducible + _suma_deducible;

		   end foreach

	  
	  let _concatena_depen = '';
	      foreach
				 select cod_cliente
				 	   into _cod_contratante
				 	   from emidepen
				 where no_poliza = _no_poliza

				 select nombre
				   	   into _nombre_asegurado
				 from cliclien
				 where cod_cliente = _cod_contratante;
				
			    let _concatena_depen = _nombre_asegurado|| ' ---  ' ||_concatena_depen;

	       end foreach

		return _no_documento,
		       _nombre_pagador,
			   _no_poliza,
			   _nombre_formapa,
			   _cod_formapag,
			   _nombre_perpago,
			   _cod_perpago,
			   _nombre_producto,
			   _suma_deducible,
			   _concatena_depen,
		       0 with resume;
  end if

end foreach

end procedure