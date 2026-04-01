-- Procedimiento que Genera el Html Body de Red Ancon Premier Care
-- Creado    : 24/07/2024 - Autor: Henry Giron

Drop procedure sp_par388; 
CREATE PROCEDURE "informix".sp_par388(  
a_secuencia	INTEGER 
)returning	Lvarchar(max),
            Lvarchar(max),
            Lvarchar(max); 

Define _html_body1	 Lvarchar(max); -- char(512); 
Define _html_body2	 Lvarchar(max); -- char(512); 
Define _html_body3	 Lvarchar(max); -- char(512); 

define _error				integer; 
define _siguiente			integer; 
define _error_isam			integer; 
define _error_desc			char(100); 

define v_asegurado	    	varchar(50); 
define v_no_documento		char(13);
define v_vigenciainicial	date;
define v_aumento            dec(5,2);
define v_montoaumento       dec(16,2);
define v_prima_actual       dec(16,2);
define v_prima_nueva        dec(16,2);
define v_porcbandaedad      dec(5,2);
define v_montobandaedad     dec(16,2);
define v_porcsiniest        dec(5,2);
define v_montosiniest       dec(16,2);
define v_corredor           varchar(200);
define v_contratante        varchar(100);

define a_no_documento      char(20);
define a_cod_asegurado      char(10);


define v_no_unidad			char(5);
define v_no_tramite			char(10);
define 	_no_solicitud		CHAR(50);
define v_placa              char(10);

define v_anosreclamos       smallint;
define v_siniest_acumulada  dec(16,2);
define _fecha_letra         varchar(25); 
define v_opcion             smallint;

define	_llave	INTEGER;
define	_poliza	CHAR(20);
define	_cod_producto	CHAR(5);
define	_n_producto	VARCHAR(100);
define	_cod_asegurado	CHAR(10);
define	_n_asegurado	VARCHAR(100);
define	_cod_corredor	CHAR(5);
define	_n_corredor	VARCHAR(100);
define	_email_asegurado	VARCHAR(100);
define	_email_corredor	VARCHAR(100);
define	_Generar_Carnet	CHAR(15);
define	_enviado	SMALLINT;
define	_fecha_envio	DATE;
define	_secuencia	INTEGER;



on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0,0,0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par388.trc"; 
--trace on;


Let  _html_body1 = '';
Let  _html_body2 = '';
Let  _html_body3 = '';

--	Select no_remesa,
--	       no_documento
--	  into a_cod_asegurado,
--	       a_no_documento
--	  from parmailcomp
--	 where mail_secuencia = a_secuencia; 

	foreach
	 select llave,
			NVL(poliza,''),
			cod_producto,
			n_producto,
			NVL(cod_asegurado,''),
			NVL(n_asegurado,''),
			cod_corredor,
			NVL(n_corredor,''),
			NVL(email_asegurado,''),
			NVL(email_corredor,''),
			NVL(Generar_Carnet,''),
			enviado,
			fecha_envio,
			secuencia
	   into _llave,
			_poliza,
			_cod_producto,
			_n_producto,
			_cod_asegurado,
			_n_asegurado,
			_cod_corredor,
			_n_corredor,
			_email_asegurado,
			_email_corredor,
			_Generar_Carnet,
			_enviado,
			_fecha_envio,
			_secuencia
       from deivid_tmp:carta_021
	  where secuencia = a_secuencia and enviado = 0
	  --  and codasegurado = a_cod_asegurado
	  --order by no_documento
	  

let _fecha_letra = sp_fecha_letra(today);	  

Let  _html_body1 = trim(_html_body1) || '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /></head><body style="font-family:Arial; font-size:14px; text-align:justify;"><table width="800"><tr><td><p style="margin:1px; padding:1px;font-weight:bold;"><br>Estimado Sr./Sra. Asegurado(a): ';
Let  _html_body2 = trim(_html_body2) || upper(trim(_n_asegurado)); --||' ( '||lower(trim(_cod_asegurado))||' ) ';
Let  _html_body3 = trim(_html_body3) || '<br/></p></td></tr><tr><td><p style="margin:1px; padding:1px;"></td></tr><tr><td><p style="margin:1px; padding:1px;">Por medio del presente, adjuntamos comunicado ampliando la informaci&oacute;n previa con relaci&oacute;n a la Red Premier Care,</p></td></tr><tr><td><p style="margin:1px; padding:1px;">la cual inicia en su Plan de Salud a partir de agosto 2024.<br></p></td></tr><tr><td><p style="margin:1px; padding:1px;"></p></td></tr><tr><td><p style="margin:1px; padding:1px;">Quedamos a disposici&oacute;n en caso de requerir m&aacute;s informaci&oacute;n.</p></td></tr><tr><td><p style="margin:1px; padding:1px;">Atentamente,</p></td></tr><tr><td><p style="margin:1px; padding:1px;">Aseguradora Anc&oacute;n</p></td></tr></table>';


return _html_body1,_html_body2,_html_body3  with resume;

END FOREACH;
--trace off;
END PROCEDURE

