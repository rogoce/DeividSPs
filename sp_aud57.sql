-- Pólizas de colectivo de vida para Palumbo
-- 
-- Creado    : 26/03/2019 - Autor: Amado Pérez M.
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_aud57;

CREATE PROCEDURE "informix".sp_aud57()
returning char(20) as Poliza,
          date as Vigencia_1,
		  char(10) as cod_aseg,
		  varchar(100) as Asegurado,
		  smallint as Edad,
		  char(1) as Sexo,
          dec(16,2) as Suma_Aseg,
		  char(1) as cod_status,
		  char(10) as Estatus;

define _no_poliza		char(10);
define _no_documento    char(20);
define _cod_status   	char(1);
define _cod_contratante	char(10);
define _nombre			varchar(100);
define _suma_asegurada  dec(16,2);
define _fecha_aniversario date;
define _sexo            char(1);
define _edad            smallint;
define _vigencia_inic   date;
define _status          char(10);


--set debug file to "sp_rwf12.trc";
--trace on;

--begin work;


foreach
	select no_documento,
	       no_poliza,
	       cod_status
	  into _no_documento,
	       _no_poliza,
		   _cod_status
	  from emipoliza
	 where cod_ramo ='016' 
	 
	select cod_contratante,
	       suma_asegurada
	  into _cod_contratante,
	       _suma_asegurada
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select nombre,
	       fecha_aniversario, 
	       sexo
      into _nombre,
	       _fecha_aniversario,
	       _sexo
      from cliclien
     where cod_cliente = _cod_contratante;

     let _edad = sp_sis78(_fecha_aniversario);    	 
	  
	foreach
		select vigencia_inic
		  into _vigencia_inic
		  from emipomae
		 where no_documento = _no_documento
		order by no_poliza
		exit foreach;
    end foreach	
	
	if _cod_status = 1 then
		let _status = 'VIGENTE';
	elif _cod_status = 2 then
		let _status = 'CANCELADA';
	elif _cod_status = 3 then
		let _status = 'VENCIDA';
	else
		let _status = 'ANULADA';
	end if
	return _no_documento,
	       _vigencia_inic,
		   _cod_contratante,
		   _nombre,
		   _edad,
		   _sexo,
		   _suma_asegurada,
		   _cod_status,
		   _status with resume;
	
end foreach

end procedure