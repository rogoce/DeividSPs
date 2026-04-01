-- Control de Preautorizaciones diarias.
-- Creado  : 04/05/2010 -  Autor: Henry Gir¢n

DROP PROCEDURE sp_rec710;
CREATE PROCEDURE "informix".sp_rec710(a_fecha date)
returning  char(20),                     -- no_documento,
		   char(10),					 -- no_aprobacion,
		   char(10),					 -- cod_reclamante,
		   char(100),					 -- reclamante,
		   char(10),					 -- cod_cpt1,
		   char(100),					 -- n_cod_cpt1,
		   datetime year to fraction(5), -- fecha_solicitud,
		   char(10),					 -- u_change,
		   datetime year to fraction(5), -- f_change, 
		   char(100),					 -- _n_estado
		   char(100) ;                   -- _n_estado_ant

define _fecha_solicitud     datetime year to fraction(5);
define _fecha_autorizacion  datetime year to fraction(5);
define _f_change		 	datetime year to fraction(5);
define _no_aprobacion	    char(10);
define _cod_hospital	    char(10);
define _cod_reclamante	 	char(10);
define _cod_icd1		 	char(10);
define _cod_cpt1		 	char(10);
define _cod_entrada		 	char(10);
define _autorizado_por   	char(10);
define _no_poliza        	char(10);
define _cod_asegurado    	char(10);
define _u_change         	char(10);
define _reclamante	     	char(100);
define _hospital	     	char(100);
define _n_estado         	char(100);
define _n_estado_ant     	char(100);
define _cod_ajustador       char(3);
define _no_documento	    char(20);
define _producto         	char(50);
define _n_cod_icd1		 	char(255);
define _n_cod_cpt1		 	char(255);
define _total_dias       	integer;
define _valido_dias      	integer;
define _anestesia        	integer;
define _estado           	smallint;
define _estado_ant       	smallint;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec710.trc";
--trace on;

LET _estado_ant = 0;

foreach
	SELECT no_aprobacion,
		   cod_reclamante,
		   no_documento,
		   cod_cliente,
		   total_dias,
		   anestesia,
		   valido_dias,
		   autorizado_por,
		   fecha_solicitud,
		   fecha_autorizacion,
		   cod_icd1,
		   cod_cpt1,
		   user_changed,
		   date_changed,
		   estado,
		   estatus_changed
	  INTO _no_aprobacion,
	       _cod_reclamante,
		   _no_documento,
		   _cod_hospital,
		   _total_dias,
		   _anestesia,
		   _valido_dias,
		   _autorizado_por,
		   _fecha_solicitud,
		   _fecha_autorizacion,
		   _cod_icd1,
		   _cod_cpt1,
		   _u_change,
		   _f_change,
		   _estado,
		   _estado_ant
	  FROM recprea1
	 WHERE date(fecha_solicitud) = a_fecha
	 ORDER BY fecha_solicitud

	SELECT nombre
	  INTO _hospital
	  FROM cliclien
	 WHERE cod_cliente = _cod_hospital;

	SELECT nombre
	  INTO _reclamante
	  FROM cliclien
	 WHERE cod_cliente = _cod_reclamante;

	SELECT nombre
	  INTO _n_cod_icd1			  -- Diagnostico
	  FROM recicd
	 WHERE cod_icd = _cod_icd1;

	SELECT nombre				  -- Procedimiento
	  INTO _n_cod_cpt1
	  FROM reccpt
	 WHERE cod_cpt = _cod_cpt1;

	if _n_cod_icd1 is null then
		let _n_cod_icd1 = "";
	end if

	if _n_cod_cpt1 is null then
		let _n_cod_cpt1 = "";
	end if

	let _no_poliza = sp_sis21(_no_documento);

	LET _n_estado = "";
	if _estado = 0 then
		LET _n_estado = "PENDIENTE";
	end if
	if _estado = 1 then
		LET _n_estado = "AUTORIZADA";
	end if
	if _estado = 2 then
		LET _n_estado = "NO AUTORIZADA";
	end if

	LET _n_estado_ant = "";
	if _estado_ant = 0 then
		LET _n_estado_ant = "PENDIENTE";
	end if
	if _estado_ant = 1 then
		LET _n_estado_ant = "AUTORIZADA";
	end if
	if _estado_ant = 2 then
		LET _n_estado_ant = "NO AUTORIZADA";
	end if

	if _n_estado_ant is null then
		let _n_estado_ant = "PENDIENTE";
	end if

   return _no_documento,
	      _no_aprobacion,
	      _cod_reclamante,
		  _reclamante,
		  _cod_cpt1,
		  _n_cod_cpt1,
		  _fecha_solicitud,
		  _u_change,
		  _f_change,
		  _n_estado,
		  _n_estado_ant
		  with resume;
end foreach

END PROCEDURE  