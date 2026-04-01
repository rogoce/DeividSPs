-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis36bk1;

CREATE PROCEDURE "informix".sp_sis36bk1() 
RETURNING char(10),char(20),char(10),smallint,char(10);

DEFINE _no_documento char(20);
DEFINE _no_requis char(10);
DEFINE _no_devleg char(10);
DEFINE _no_remesa char(10);
define _cnt,_firma_electronica  smallint;
define _desc_error			char(100);
define _error integer;
define _e_mail_corredor		varchar(50);
define _renglon   integer;

-- Descomponer los periodos en fechas

foreach

select no_requis,no_devleg,no_documento,firma_electronica,no_remesa
  into _no_requis,_no_devleg,_no_documento,_firma_electronica,_no_remesa
  from cobdevleg

	
  select count(*)
    into _cnt
	from chqchmae
   where no_requis = _no_requis;

    if _cnt is null then
		let _cnt = 0;
    end if	
	
	if _cnt = 0 then
		update cobdevleg
		   set no_requis = ''
		 where no_devleg = _no_devleg;
		foreach 
		select renglon
		  into _renglon
		  from cobredet
		 where no_remesa  = _no_remesa
		   and doc_remesa = _no_documento
		   and tipo_mov   = 'K'
		   
		call sp_che138(_no_remesa, _renglon) returning _error, _desc_error, _no_requis, _e_mail_corredor;
        
		update cobdevleg
		   set no_requis = _no_requis
		 where no_devleg = _no_devleg;
		end foreach 
		return _no_devleg,_no_documento,_no_requis,_firma_electronica,_no_remesa with resume;
	end if
  
end foreach


END PROCEDURE;