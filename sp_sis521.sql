-- Procedimiento para buscar registros de cobenvau para proceso de envio de correos a corredores
-- Diario sis100
-- Creado: 06/06/2025 - Autor: Armando Moreno

DROP PROCEDURE sp_sis521;
CREATE PROCEDURE sp_sis521(a_cod_agente char(5), a_no_remesa char(10), a_tipo smallint)
RETURNING char(20), CHAR(50), CHAR(10), CHAR(10), CHAR(50), CHAR(50), char(30), char(30),char(10), date, dec(16,2);

DEFINE	_estatus_poliza,_cod_contratante	CHAR(10);
define _no_documento    			        char(20);
define _n_ramo,_n_contratante,_n_asegurado  char(50);
define _monto			dec(16,2);
define _e_mail_contr    char(30);
define _celular,_no_poliza,_cod_asegurado	char(10);
define _cod_ramo        char(3);
define _ced_asegurado   char(12);
define _fecha_remesa    date;
define _cnt smallint;

BEGIN

let _cnt = 0;

foreach
	select no_documento,
	       cod_ramo,
		   monto
	  into _no_documento,
	       _cod_ramo,
		   _monto
	  from cobenvau
	 where tipo = a_tipo
       and enviado = 0
	   and no_remesa = a_no_remesa
	   
	select fecha
      into _fecha_remesa
      from cobremae
     where no_remesa = a_no_remesa;

	select nombre
	  into _n_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	 
	select no_poliza
	  into _no_poliza
	  from emipoliza
	 where no_documento = _no_documento;

	select cod_contratante,
	       decode(estatus_poliza,1,'Vigente',2,'Cancelada',3,'Vencida',4,'Anulada')
	  into _cod_contratante,
	       _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select count(*)
	  into _cnt
	  from emipouni
	 where no_poliza = _no_poliza;

    if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt > 1 then
		let _n_asegurado = "VER UNIDADES";
		let _ced_asegurado = "VER UNIDADES";
	else
		select cod_asegurado into _cod_asegurado from emipouni
		where no_poliza = _no_poliza;
		
		select cedula,
			   nombre
		  into _ced_asegurado,
			   _n_asegurado
		  from cliclien
		 where cod_cliente = _cod_asegurado;
	end if
	 
	select e_mail,
	       celular,
		   nombre
      into _e_mail_contr,
	       _celular,
		   _n_contratante
	  from cliclien
	 where cod_cliente = _cod_contratante; 

	return _no_documento,_n_ramo,_estatus_poliza,_cod_contratante,_n_contratante,_n_asegurado,_ced_asegurado,_e_mail_contr,_celular,_fecha_remesa,_monto with resume;
end foreach
END
END PROCEDURE
