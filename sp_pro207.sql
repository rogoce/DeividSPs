-- Reporte de Asignacion de Evaluaciones
-- Creado    : 08/04/2011 - Autor: Henry Giron
DROP PROCEDURE sp_pro207;
CREATE PROCEDURE "informix".sp_pro207( a_fecha1 date, a_fecha2 date )
returning char(10),datetime year to fraction(5),char(10),varchar(100),smallint,smallint,smallint,char(8),date,date,char(15),char(8),varchar(100),varchar(20);

define _n_contratante    varchar(100);
define _nom_tipo_ramo	 char(15);
define _no_evaluacion	 char(10);
define _fecha			 datetime year to fraction(5);
define _no_recibo		 char(10);
define _fecha_recibo	 date;
define _monto			 decimal(16,2);
define _cantidad	     integer;
define _cod_asegurado    char(10);
define _cod_producto     char(5);
define _es_medico        smallint;
define _fecha_eval       date;
define _fecha_hora       datetime hour to fraction(5);
define _decicion         smallint;
define _suspenso         smallint;
define _completado       smallint;
define _tipo_ramo		 smallint;
define _usuario_eval     char(8);
define _fecha_compl		 date;
define _user_added       char(8);
define n_user_added      char(100);
define _no_poliza        char(10);
define _no_documento     char(20);


SET ISOLATION TO DIRTY READ;

create temp table tmp_pro207(
	no_evaluacion	char(10),							
	fecha			datetime year to fraction(5),		
	cod_asegurado	char(10),							
	n_contratante	varchar(100),						
	decicion		smallint,							
	suspenso		smallint,							
	completado		smallint,							
	usuario_eval	char(8),							
	fecha_eval		date,								
	fecha_compl		date,								
	nom_tipo_ramo 	char(15),							
	user_added      char(8),							
	n_user_added	varchar(100),						
	no_documento	varchar(20),
	PRIMARY KEY (no_evaluacion)
	) with no log;

--CREATE INDEX xie01_tmp_pro207 ON tmp_pro207(no_evaluacion);

--SET DEBUG FILE TO "sp_pro207.trc";
--trace on;

SET LOCK MODE TO WAIT;
BEGIN

foreach					  
	SELECT no_evaluacion,
		   fecha,
		   cod_asegurado,
		   no_poliza,
		   decicion,
		   suspenso,
		   completado,
		   usuario_eval,
		   tipo_ramo,
		   date(fecha_obs_eval),
		   date(fecha_completado)
	  INTO _no_evaluacion,
		   _fecha,
		   _cod_asegurado,
		   _no_poliza,
		   _decicion,
		   _suspenso,
		   _completado,
		   _usuario_eval,
		   _tipo_ramo,
		   _fecha_eval,
		   _fecha_compl
	  FROM emievalu
	 WHERE fecha >= a_fecha1			-- usuario_eval = "EVALUACI" AND 
	   AND fecha <= a_fecha2
	 ORDER BY fecha			

	if _cod_asegurado is null or _cod_asegurado = "" then
		continue foreach;
	end if

    select user_added, no_documento
	  into _user_added, _no_documento
      from emipomae
	 where no_poliza  = _no_poliza;

	if _user_added = "EVALUACI" then
		continue foreach;
	end if

	if _tipo_ramo = 1 then
		let _nom_tipo_ramo = 'Salud';
	elif _tipo_ramo = 2 then
		let _nom_tipo_ramo = 'Vida';
	elif _tipo_ramo = 3 then
		let _nom_tipo_ramo = 'Accidentes';
	end if

	select nombre
	  into _n_contratante
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	if _decicion in(3,8) then
		let _decicion = 2;
	elif _decicion in(4,5,9,7,2,11,10) then
		let _decicion = 3;
	elif _decicion = 6 then
		let _decicion = 4;
	end if

	SELECT upper(trim(descripcion))
	  INTO n_user_added
	  FROM insuser 
	 WHERE upper(trim(usuario)) = upper(trim(_user_added)) 
	   AND trim(status)         = 'A' ;

	BEGIN
	ON EXCEPTION IN(-239)
{		UPDATE tmp_pro207
		   SET usuario_eval  = _usuario_eval
		 WHERE no_evaluacion = _no_evaluacion ; }
	END EXCEPTION

		INSERT INTO tmp_pro207(
		no_evaluacion,	
		fecha,			
		cod_asegurado,	
		n_contratante,	
		decicion,		
		suspenso,		
		completado,		
		usuario_eval,	
		fecha_eval,		
		fecha_compl,		
		nom_tipo_ramo,
		user_added,
		n_user_added,
		no_documento )		
		VALUES(
		_no_evaluacion,
		_fecha,
		_cod_asegurado,
		_n_contratante,
		_decicion,
		_suspenso,
		_completado,
		_usuario_eval,
		_fecha_eval,
		_fecha_compl,
		_nom_tipo_ramo,
		_user_added,
		n_user_added,
		_no_documento 
		);

	END 	
	   

end foreach
foreach					  
	SELECT no_evaluacion,
		   fecha,			
		   cod_asegurado,
		   n_contratante,
		   decicion,		
		   suspenso,		
		   completado,		
		   usuario_eval,	
		   fecha_eval,		
		   fecha_compl,	
		   nom_tipo_ramo,
		   user_added,
		   n_user_added,
		   no_documento 		   
	  INTO _no_evaluacion,
		   _fecha,
		   _cod_asegurado,
		   _n_contratante,
		   _decicion,
		   _suspenso,
		   _completado,
		   _usuario_eval,
		   _fecha_eval,
		   _fecha_compl,
		   _nom_tipo_ramo,
		   _user_added,
		   n_user_added,
		   _no_documento 	   		   		   		   
	  FROM tmp_pro207  
	 ORDER BY fecha


	Return _no_evaluacion,
		   _fecha,
		   _cod_asegurado,
		   _n_contratante,
		   _decicion,
		   _suspenso,
		   _completado,
		   _usuario_eval,
		   _fecha_eval,
		   _fecha_compl,
		   _nom_tipo_ramo, 
		   _user_added,
		   n_user_added,
		   _no_documento		   
		   with resume;	   

end foreach

END
END PROCEDURE

  		 