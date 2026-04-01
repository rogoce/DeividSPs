-- Procedimiento que Unifica las Marcas
-- 
-- Creado    : 24/05/2012 - Autor: Armando Moreno M.
-- Modificado: 24/05/2012 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro221;
CREATE PROCEDURE "informix".sp_pro221()
       RETURNING char(5),
       			 varchar(50),
       			 integer,
       			 smallint,
       			 smallint,
       			 char(10);

define _cnt  			   integer;
define _cod_marca		   char(5);
define _n_marca  		   varchar(50);
define _porc_rec_ded_coli  dec(16,2);
define _requiere_aprob_tec smallint;
define _tiene_rec_ded      smallint;
define _marca_inma		   char(10);
	
SET ISOLATION TO DIRTY READ;

begin

foreach
	select cod_marca,
	       nombre,
		   tiene_rec_ded,
		   requiere_aprob_tec,
		   marca_inma
	  into _cod_marca,
		   _n_marca,
		   _tiene_rec_ded,
		   _requiere_aprob_tec,
		   _marca_inma
	  from emimarca
--	 where activo = 1
	  order by nombre

    select count(*)
	  into _cnt
	  from emimodel
	 where cod_marca = _cod_marca;

	return _cod_marca,_n_marca,_cnt,_tiene_rec_ded,_requiere_aprob_tec, _marca_inma with resume;

end foreach

END

END PROCEDURE