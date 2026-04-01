-- Control de Preautorizaciones Pendientes. Reclamos de vida y Salud.

-- Creado    : 09/08/2007 - Autor: Armando Moreno.

DROP PROCEDURE sp_rec146;

CREATE PROCEDURE "informix".sp_rec146()
returning integer,					   --error
		  char(10),					   --no_aprobacion
		  char(10),					   --cod_reclamante
		  char(100),                   --nom reclamante
		  char(20),					   --no_doc
		  char(10),					   --cod_hospital
		  char(100),				   --nom hospital
		  datetime year to fraction(5),--fecha solicitud
		  datetime year to fraction(5),--fecha autorizacion
		  char(10),					   --autorizado_por
		  integer,					   --total_dias
		  integer,					   --valido_dias
		  integer,					   --anestecia
		  char(10),					   --cod_icd1
		  char(10),					   --cod_cpt1
		  char(100),				   --nom_icd
		  char(100),				   --nom_cpt
		  char(20);                    -- n_estado

define _no_aprobacion	    char(10);
define _fecha_solicitud     datetime year to fraction(5);
define _fecha_autorizacion  datetime year to fraction(5);
define _cod_ajustador    char(3);
define _cantidad	     integer;
define _no_documento	 char(20);
define _cod_hospital	 char(10);
define _cod_reclamante	 char(10);
define _reclamante	     char(100);
define _hospital	     char(100);
define _producto         char(50);
define _cod_icd1		 char(10);
define _cod_cpt1		 char(10);
define _n_cod_icd1		 char(255);
define _n_cod_cpt1		 char(255);
define _cod_entrada		 char(10);
define _autorizado_por   char(10);
define _total_dias       integer;
define _valido_dias      integer;
define _anestesia        integer;
define _estado        integer;
define _n_estado        char(20);



SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec146.trc";
--trace on;
let _n_estado = '';
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
			   estado
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
			   _estado
		  FROM recprea1
		 WHERE no_documento = '1819-99900-01' 
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
		  INTO _n_cod_icd1
		  FROM recicd
		 WHERE cod_icd = _cod_icd1;

		SELECT nombre
		  INTO _n_cod_cpt1
		  FROM reccpt
		 WHERE cod_cpt = _cod_cpt1;

		if _n_cod_icd1 is null then
			let _n_cod_icd1 = "";
		end if
		if _n_cod_cpt1 is null then
			let _n_cod_cpt1 = "";
		end if
		
		if _estado = 0 then
			let _n_estado = "PENDIENTE";
		end if
		if _estado = 1 then
			let _n_estado = "AUTORIZADO";
		end if
		if _estado = 2 then
			let _n_estado = "NO AUTORIZADO";
		end if		

	   return 0,
	   		  _no_aprobacion,
	   		  _cod_reclamante,
			  _reclamante,
			  _no_documento,
			  _cod_hospital,
			  _hospital,
			  _fecha_solicitud,
			  _fecha_autorizacion,
			  _autorizado_por,
			  _total_dias,
			  _valido_dias,
			  _anestesia,
			  _cod_icd1,
			  _cod_cpt1,
			  _n_cod_icd1,
			  _n_cod_cpt1,
			  _n_estado
			  with resume;
end foreach
END PROCEDURE
