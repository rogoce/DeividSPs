-- Procedure que crea el reclamo coaseguros

-- Creado: 14/05/2019 - Autor: Amado Perez

drop procedure sp_rec289b;

create procedure "informix".sp_rec289b(a_cod_compania    char(3),
                                     a_cod_sucursal     char(3),
                                     a_no_documento 	char(30), 
                                     a_no_unidad 		char(5), 
									 a_fecha_siniestro  date,
									 a_monto            dec(16,2),
									 a_usuario 		    char(8),
									 a_descripcion      varchar(60),
									 a_no_reclamo_coaseg char(30) default null)
returning integer,
          char(150),
		  varchar(20),
		  varchar(50),
		  char(10),
		  char(18);

define v_cod_asegurado1     char(10);
define v_cod_producto       char(5);
define v_suma_asegurada     dec(16,2);
define _fecha_actual        date;
define _periodo_hoy         char(7);
define v_no_tranrec         char(10);
define v_no_reclamo         char(10);
define v_numrecla           char(20);
define v_no_trans           char(10);
define _hora, _hora2        datetime hour to fraction(5);
define _no_poliza           char(10);
define _cod_cobertura       char(5);
define _cod_ajustador       char(3);
define v_no_motor           char(30);
define v_asegurado          varchar(100);
define _contador            smallint;

define _error	   			integer;
define _error_isam 			integer;
define _error_desc 			char(50);

define _cod_ramo            char(3);
define _cod_tiporamo        char(3);
define _cod_area            smallint;
define _nombre              varchar(50);
define _cod_evento          char(3);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || trim(_error_desc) ,a_no_documento,"","", "";
end exception

--SET DEBUG FILE TO "sp_rec289.trc";
--TRACE ON ;

    let a_no_documento = a_no_documento;
	let _fecha_actual = today;
	let _hora         = current;
	let _hora2         = '10:00:00';
	let _cod_cobertura = null;
	let v_no_trans = null;
	let v_asegurado = null;
	let v_numrecla = null;
	
	if a_no_documento is null or trim(a_no_documento) = "" then
		return 1, "El No documento está en nulo o en blanco por favor corregir ","","","", "";
	end if

	--call sp_sis39(_fecha_actual) RETURNING _periodo_hoy;
	
	let _contador = 0;
	
	select count(*)
	  into _contador
	  from emipomae
	 where no_documento = a_no_documento
       and actualizado = 1
       and vigencia_inic <= a_fecha_siniestro
       and vigencia_final >= a_fecha_siniestro;

	if _contador = 0 then
		let _contador = 0;
		
		select count(*)
		  into _contador
		  from emipomae
		 where no_poliza_coaseg = a_no_documento
		   and actualizado = 1;
		   
		if _contador = 0 then
			return 1, "La poliza no existe en Deivid", a_no_documento,"","", "";
		end if
	
		select count(*)
		  into _contador
		  from emipomae
		 where no_poliza_coaseg = a_no_documento
		   and actualizado = 1
		   and vigencia_inic <= a_fecha_siniestro
		   and vigencia_final >= a_fecha_siniestro;
		if _contador = 0 then
			return 1, "Fecha de siniestro fuera del rango de vigencia", a_no_documento,"","", "";
		else
			foreach
				select no_documento,
				       cod_ramo
				  into a_no_documento,
				       _cod_ramo
				  from emipomae
				 where no_poliza_coaseg = a_no_documento
				   and actualizado = 1
				   and vigencia_inic <= a_fecha_siniestro
				   and vigencia_final >= a_fecha_siniestro
			end foreach				   
		end if
	end if

	let _contador = 0;

	IF a_no_reclamo_coaseg IS NOT NULL AND TRIM(a_no_reclamo_coaseg) <> "" THEN	
		select count(*)
		  into _contador
		  from recrcmae a, rectrmae b
		 where a.no_reclamo = b.no_reclamo
		   and a.no_documento = a_no_documento
		   and a.actualizado = 1
		   and a.fecha_siniestro = a_fecha_siniestro
		   and b.cod_tipotran = '004'
		   and b.actualizado = 1
		   and b.monto = a_monto
		   and a.no_reclamo_coaseg = a_no_reclamo_coaseg;
	ELSE
		select count(*)
		  into _contador
		  from recrcmae a, rectrmae b
		 where a.no_reclamo = b.no_reclamo
		   and a.no_documento = a_no_documento
		   and a.actualizado = 1
		   and a.fecha_siniestro = a_fecha_siniestro
		   and b.cod_tipotran = '004'
		   and b.actualizado = 1
		   and b.monto = a_monto;
	END IF
	
	if _contador > 0 then
		foreach
			select a.numrecla
			  into v_numrecla
			  from recrcmae a, rectrmae b
			 where a.no_reclamo = b.no_reclamo
			   and a.no_documento = a_no_documento
			   and a.actualizado = 1
			   and a.fecha_siniestro = a_fecha_siniestro
			   and b.cod_tipotran = '004'
			   and b.actualizado = 1
			   and b.monto = a_monto
			
			exit foreach;
		end foreach

		return 1, " Reclamo ya creado: " || v_numrecla, a_no_documento,"","", "";	
	end if
	
	select cod_tiporamo,
	       cod_area,
		   nombre
	  into _cod_tiporamo,
	       _cod_area,
		   _nombre
	  from prdramo
     where cod_ramo = _cod_ramo;

    if _cod_tiporamo <> '002' then
		return 1, " El ramo " || _cod_ramo || " " || trim(_nombre) || " no es procesable", a_no_documento,"","", "";
	end if	
	
	FOREACH
		select no_poliza,
		       cod_contratante
		  into _no_poliza,
		       v_cod_asegurado1
		  from emipomae
		 where no_documento = a_no_documento
		   and actualizado = 1
		   and vigencia_inic <= a_fecha_siniestro
		   and vigencia_final >= a_fecha_siniestro
		 order by vigencia_final desc

		exit foreach;
	END FOREACH

	let _contador = 0;

    SELECT count(*)
	  INTO _contador
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = a_no_unidad;

	if _contador = 0 then
		return 1, "La unidad " || a_no_unidad || " no existe" , a_no_documento,"","", "";
	end if

    LET _cod_ajustador = NULL; 	   
	   
	SELECT cod_ajustador
      INTO _cod_ajustador
      FROM recajust
     WHERE usuario = a_usuario;	 

    IF _cod_ajustador IS NULL OR TRIM(_cod_ajustador) = "" THEN
		return 1, "Debe ser procesado por un ajustador",a_no_documento,"","", "";
    END IF	


end
return 0, "Exito",v_numrecla,trim(v_asegurado),v_no_trans, a_no_documento;

end procedure