-- Busqueda del caso mas viejo cuando le dan nuevo programa de consulta de solicitudes.

-- Creado    : 28/10/2010 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro212;

CREATE PROCEDURE "informix".sp_pro212(a_no_eval char(10))
returning integer,varchar(100),char(10),smallint,char(50),smallint;

define _asegurado        varchar(100);
define _cod_asegurado    char(10);
define _cod_depend       char(10);
define _principal        smallint;
define _cod_parentesco   char(3);
define _procesado        smallint;
define _n_paren          char(50);
define _n_nombre_paren   varchar(100);

--SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro194.trc";
--trace on;

SET LOCK MODE TO WAIT;

create temp table tmp_eva(
principal   smallint,
nombre   	varchar(100),
codigo      char(10),
aplica      smallint,
parentesco  char(30)
);


BEGIN


			SELECT cod_asegurado
			  INTO _cod_asegurado
			  FROM emievalu
			 WHERE no_evaluacion = a_no_eval
			   AND escaneado    = 1
			   AND completado   = 0;

			select nombre
			  into _asegurado
			  from cliclien
			 where cod_cliente = _cod_asegurado;


			insert into tmp_eva(principal,nombre,codigo,aplica,parentesco)
			values (1, _asegurado,_cod_asegurado,1,"");

			foreach

				select cod_asegurado,
				       cod_parentesco,
					   procesado
				  into _cod_depend,
				       _cod_parentesco,
					   _procesado
				  from emievade
				 where no_evaluacion = a_no_eval

				select nombre
				  into _n_paren
				  from emiparen
				 where cod_parentesco = _cod_parentesco;

				select nombre
				  into _n_nombre_paren
				  from cliclien
				 where cod_cliente = _cod_depend;

				insert into tmp_eva(principal,nombre,codigo,aplica,parentesco)
				values (0, _n_nombre_paren,_cod_depend,_procesado,_n_paren);

            end foreach


		   foreach

				select principal,
					   nombre,   	
					   codigo,    
					   aplica,    
				 	   parentesco
				  into _principal,
				       _n_nombre_paren,
					   _cod_depend,
					   _procesado,
					   _n_paren
				  from tmp_eva 

				 Return	_principal,
					    _n_nombre_paren,
					    _cod_depend,
					    _procesado,
					    _n_paren,_principal with resume;

		   end foreach

drop table tmp_eva;
END
END PROCEDURE
