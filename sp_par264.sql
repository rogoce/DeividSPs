-- Informaci¢n: Actualiza los cliente  Agrupador Porcesados y no permite ser actualizados nuevamente
-- Creado     : 07/10/2007 - Autor: Rub‚n Dar¡o Arn ez S nchez
-- DROP PROCEDURE sp_par264;
create procedure "informix".sp_par264(a_cod_correcto char(10), a_cod_agrupa char(3))
returning integer,
          char(100),
		  char(10),
		  integer,
          smallint,
		  char(3),
          smallint,
          smallint,
          char(58);

DEFINE	  _cod_clt    char(10);
DEFINE	  _cod_gpo    char(4);
DEFINE    _seleccion  smallint;
DEFINE    _declinados smallint;             
DEFINE 	  _cod_agrupa char(3);
DEFINE 	  _estado     smallint;
DEFINE	  _nombre     char(58);

define _cnt			  integer;
define _cnt1		  integer;


SET ISOLATION TO DIRTY READ;

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
	  select count(*)
		into _cnt
		from clidedup
		where cod_clt   = a_cod_correcto
		  and seleccion = 1;
		 
		if _cnt > 0 then
	       let _seleccion  = 1;
		   let _declinados = 1;
	  	   
			update clidedup
			   set declinados = _seleccion
			 where cod_clt    = a_cod_correcto
			   and cod_gpo    = a_cod_agrupa;
		   
		end if

		select count(*)
		into _cnt1
		from clideagr
		where cod_agrupa = a_cod_agrupa;

		if _cnt1 > 0 then
	       let _estado = 1;

		   select nombre
			 into _nombre
			 from clideagr
			where cod_agrupa = a_cod_agrupa;

		 
		   UPDATE clideagr 
		      SET estado       = _estado       
	        WHERE cod_agrupa   = a_cod_agrupa;
		end if
   
return 	 0,
		 "Actualizacion Exitosa",
		 a_cod_correcto,
		 _cnt,
		 _seleccion,
		 a_cod_agrupa,           
		 _declinados,
		 _estado,
		 _nombre 
      with resume;


end procedure;
