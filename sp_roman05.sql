--***********************************************************************
-- Procedimiento que genera Info. para Guillermo de productos de salud
--***********************************************************************
-- Creado    : 15/01/2024 - Autor: Armando Moreno M.

DROP PROCEDURE sp_roman05;
CREATE PROCEDURE sp_roman05(a_compania CHAR(3),a_sucursal CHAR(3),a_periodo char(7))
RETURNING char(5)        as cod_producto,
          char(50)      as nombre_producto,
		  char(50)      as nombre_subramo,
		  char(5)       as cod_grupo,
		  char(50)      as n_grupo,
		  varchar(100)  as contratante,
		  char(20)      as poliza,
		  integer       as unidades_activas,
		  integer       as poliza_vigente;


DEFINE _no_poliza       CHAR(10);
DEFINE _no_documento    CHAR(20); 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _nombre_ramo     CHAR(50);  
DEFINE _cod_subramo     CHAR(3);  
DEFINE _cod_producto,_cod_grupo	char(5);
define _cod_contratante char(10);
define _estatus_poliza  smallint;
define _cnt,_cnt2     integer;
define _n_contratante   varchar(100);
define _nombre_subramo	char(50);
define _n_producto,_n_grupo      char(50);


--SET DEBUG FILE TO "sp_pro868a.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _cnt2 = 0; --contador para polizas vigentes
foreach
	select cod_subramo,
	       cod_producto,
		   cod_ramo,
		   nombre
	  into _cod_subramo,
	       _cod_producto,
		   _cod_ramo,
		   _n_producto
	  from prdprod
	 where cod_ramo = '018'
	 
	let _cnt = 0; --contador para cantidad de unidades
    foreach
		select distinct no_poliza
		  into _no_poliza
		  from emipouni
		 where cod_producto = _cod_producto
		 
		select count(*)
		  into _cnt
		  from emipouni
		 where no_poliza    = _no_poliza
		   and cod_producto = _cod_producto
		   and activo       = 1;
		 
		select no_documento,
			   cod_contratante,
			   estatus_poliza,
			   cod_grupo
		  into _no_documento,
			   _cod_contratante,
			   _estatus_poliza,
			   _cod_grupo
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		if _estatus_poliza = 1 then
			let _cnt2 = 1;
		else
			let _cnt2 = 0;
		end if
		 
		select nombre
		  into _nombre_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;
		 
		select nombre
		  into _n_grupo
		  from cligrupo
		 where cod_grupo = _cod_grupo;
		  
		select nombre
		  into _nombre_subramo
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo;
		   
		select nombre
		  into _n_contratante
		  from cliclien
		 where cod_cliente = _cod_contratante;
	 
		Return _cod_producto, _n_producto, _nombre_subramo, _cod_grupo,_n_grupo,_n_contratante,_no_documento,_cnt,_cnt2 with resume;
				 
	end foreach
end foreach

END PROCEDURE;