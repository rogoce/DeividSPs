

DROP PROCEDURE sp_sis466;
CREATE PROCEDURE sp_sis466(a_no_documento CHAR(20)) RETURNING smallint;

define _no_poliza,_cod_contratante char(10);
define _cod_ramo,_cod_mala char(3);

SET ISOLATION TO DIRTY READ;


if trim(a_no_documento) = '0216-00890-03' then
	return 1;
end if

select no_poliza
  into _no_poliza
  from emipoliza
 where no_documento = a_no_documento;

select cod_contratante,
       cod_ramo
  into _cod_contratante,
       _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;
 
 if _cod_ramo = '020' then
	select cod_mala_refe
	  into _cod_mala
	  from cliclien
	 where cod_cliente = _cod_contratante;
	
	if _cod_mala in('008','009','010') then
		return 2;
	end if
	  
 end if

return 0;

END PROCEDURE;