-- Informaci¢n: Depuraci¢n de cliente  Agrupador para Presentar los datos en el Grid
-- Creado     : 23/10/2007 - Autor: Rub‚n Dar¡o Arn ez S nchez
DROP PROCEDURE sp_par263;
create procedure "informix".sp_par263()

returning char(10),
          char(58),
          char(18),
          char(55),
          char(12),
          date,
          char(4),
          decimal(9,2),
          smallint,
          smallint;

DEFINE	  _cod_clt    char(10);
DEFINE	  _nombre     char(58);
DEFINE	  _ced        char(18);
DEFINE	  _dir        char(55);
DEFINE	  _tel        char(12);
DEFINE	  _nac        date;
DEFINE	  _cod_gpo    char(4);
DEFINE	  _por        decimal(9,2);  
DEFINE    _seleccion  smallint;
DEFINE    _declinados smallint;             
-- let    _nom_  = "";

SET ISOLATION TO DIRTY READ;

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
	foreach 
		 select cod_clt,
				nombre,
				ced,
				dir,
				tel,
				nac,
				cod_gpo,
				por,
				seleccion,   
				declinados          
		   into _cod_clt,
				_nombre,
				_ced,
				_dir,
				_tel,
				_nac,
				_cod_gpo,
				_por,
				_seleccion,
                _declinados
		   from clidedup
		  where seleccion = 1

	  	  order by nombre
				   	return  _cod_clt,
							_nombre,
							_ced,
							_dir,
							_tel,
							_nac,
							_cod_gpo,
							_por,
							_seleccion,           
							_declinados  
				     with resume;
	end foreach;

 end procedure;
