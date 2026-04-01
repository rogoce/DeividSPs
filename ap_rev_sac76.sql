-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_rev_sac76;
CREATE PROCEDURE ap_rev_sac76() 
RETURNING  integer,				--Salud
		   char(20);

DEFINE 	_no_poliza		    char(10);
DEFINE 	_no_endoso			char(5);
DEFINE 	_no_remesa			char(10);
DEFINE 	_renglon		    integer;
DEFINE  _error              integer;
DEFINE  _notrx              integer;
DEFINE  _error_desc         varchar(50);


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

--begin work;

begin
on exception set _error
--    rollback work;
	return _error, "Error al Cambiar Tarifas...";
end exception


foreach 
	select distinct sac_notrx
	  into _notrx
	  from endasien
	 where sac_notrx in (
'1725226',
'1725229',
'1725230',
'1725231',
'1725232',
'1725233',
'1725234',
'1725235',
'1725236',
'1725237',
'1725238',
'1725239',
'1725240',
'1725291',
'1725292',
'1725293',
'1725294',
'1725295',
'1725296',
'1725297',
'1725298',
'1725299',
'1725300',
'1725301',
'1725302',
'1725303',
'1725304',
'1725305',
'1725306',
'1725307',
'1725308',
'1725309',
'1725311',
'1725312',
'1725313',
'1725314',
'1725315',
'1725316',
'1725317',
'1725318',
'1725319',
'1725320',
'1725321',
'1725322',
'1725323',
'1725324',
'1725429',
'1725431',
'1725432',
'1725433',
'1725434',
'1725435',
'1725436',
'1725437',
'1725438',
'1725439',
'1725440',
'1725441',
'1725442',
'1725443',
'1725444',
'1725445',
'1725446',
'1725447',
'1725448',
'1725449',
'1725450',
'1725451',
'1725452',
'1725453',
'1725455',
'1725456',
'1725457',
'1725458',
'1725459',
'1725460',
'1725461',
'1725462',
'1725464',
'1725465',
'1725466',
'1725467',
'1725468',
'1725469',
'1725470',
'1725471',
'1725472',
'1725473',
'1725474',
'1725475',
'1727268',
'1728217',
'1728619',
'1730144',
'1730656',
'1730878',
'1733350',
'1733363',
'1733375'
     )

	call sp_sac77pro(_notrx) returning _error, _error_desc;
	
	if _error = 0 then
        return _notrx, 'Actualizacion exitosa' with resume; 	    
    else
       return _notrx, _error_desc with resume;
    end if	   
end foreach
end

--commit work;
return 0, 'Actualizacion exitosa';
END PROCEDURE	  
