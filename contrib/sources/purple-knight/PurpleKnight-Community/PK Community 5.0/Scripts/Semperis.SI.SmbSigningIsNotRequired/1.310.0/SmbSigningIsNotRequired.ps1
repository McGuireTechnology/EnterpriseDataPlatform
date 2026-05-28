[CmdletBinding()]
param(
    [Parameter(Mandatory,ParameterSetName='Execution')][string]$ForestName,
    [Parameter(Mandatory,ParameterSetName='Execution')][string[]]$DomainNames,
    [Parameter(ParameterSetName='Execution')]$StartAttackWindow,
    [Parameter(ParameterSetName='Execution')]$EndAttackWindow,
    [Parameter(ParameterSetName='Metadata',Mandatory)][switch]$Metadata
)

$Global:self = @{
    ID = 154
    UUID = '0d9236c4-98a1-4763-913b-783fdfe1de4c'
    Version = '1.310.0'
    CategoryID = 3
    ShortName = 'SI000154'
    Name = 'SMB Signing is not required on Domain Controllers'
    ScriptName = 'SmbSigningIsNotRequired'
    Description = 'This indicator looks for domain controllers where SMB signing is not required.'
    Weight = 8
    Severity = 'Critical'
    Schedule = '1h'
    Impact = 8
    LikelihoodOfCompromise = '<p>Unsigned network traffic is susceptible to attacks abusing the NTLM challenge-response protocol. A common example of such attacks is SMB Relay, where an attacker is positioned between the client and the server in order to capture data packets transmitted between the two, thus gaining unauthorized access to the server or other servers on the network.</p>
      <h3>References</h3>
      <p><a href="https://techcommunity.microsoft.com/blog/filecab/configure-smb-signing-with-confidence/2418102" target="_blank">Configure SMB Signing with Confidence</a></p>'
    ResultMessage = 'Found {0} DCs that do not require SMB Signing.'
    Remediation = '<p>The following Group Policies need to be enabled in order to enforce SMB Signing on DCs:</p>
      <ol>
        <li>Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options > Microsoft network server: Digitally sign communications (always): This policy controls whether the server providing SMB required signing. It determines if SMB signing will have to be negotiated prior to further communication.</li>
        <li>Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options > Microsoft network server: Digitally sign communications (if client agrees): This policy determines if SMB server will negotiate SMB signing with clients that request it.</li></ol>'
    Types = @('IoE')
    DataSources = @('AD.LDAP')
    OutputFields = @(
        @{ Name = 'DistinguishedName'; Type = 'String'; IsCollection = $false },
        @{ Name = 'HostName'; Type = 'String'; IsCollection = $false },
        @{ Name = 'State'; Type = 'String'; IsCollection = $false }
    )
    Targets = @('AD')
    Permissions = @()
    SecurityFrameworks = @(
        @{ Name = 'MITRE ATT&CK'; Tags = @('Privilege Escalation', 'Credential Access') }
    )
    Products = @(
        @{ Name = 'HYD'; MinVersion = '1.0'; MaxVersion = '3.0'; Licenses = @('Cloud') },
        @{ Name = 'DSP'; MinVersion = '3.5'; MaxVersion = '10'; Licenses = @('DSP-I') },
        @{ Name = 'PK'; MinVersion = '1.4'; MaxVersion = '10'; Licenses = @('Community', 'Post-Breach', 'BPIR') }
    )
    IgnoreListSupport = $true
    Selected = 1
}
if($Metadata){ return $self | ConvertTo-Json -Depth 8 -Compress }

Import-Module -Name 'Semperis-Lib'

$code = @"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace SmbSigning
{
    public class SmbSigningChecking
    {
        public struct SMB_ERROR
        {
            public byte ErrorClass;
            public byte Reserved;
            public byte ErrorCode1;
            public byte ErrorCode2;

            public SMB_ERROR(byte errorClass)
            {
                ErrorClass = errorClass;
                Reserved = 0x00;
                ErrorCode1 = 0x00;
                ErrorCode2 = 0x00;
            }

        }

        [Flags]
        public enum Flags
        {
            SMB_FLAGS_LOCK_AND_READ_OK = 0x01,
            SMB_FLAGS_BUF_AVAIL = 0x02,
            Reserved = 0x04,
            SMB_FLAGS_CASE_INSENSITIVE = 0x08,
            SMB_FLAGS_CANONICALIZED_PATHS = 0x10,
            SMB_FLAGS_OPLOCK = 0x20,
            SMB_FLAGS_OPBATCH = 0x40,
            SMB_FLAGS_REPLY = 0x80,

        }

        [Flags]
        public enum Flags2
        {
            SMB_FLAGS2_LONG_NAMES = 0x0001,
            SMB_FLAGS2_EAS = 0x0002,
            SMB_FLAGS2_SMB_SECURITY_SIGNATURE = 0x0004,
            SMB_FLAGS2_IS_LONG_NAME = 0x0040,
            SMB_FLAGS2_DFS = 0x1000,
            SMB_FLAGS2_PAGING_IO = 0x2000,
            SMB_FLAGS2_NT_STATUS = 0x4000,
            SMB_FLAGS2_UNICODE = 0x8000,
        }


        public struct SMB1_HEADER
        {

            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)] public byte[] Protocol; // size 4 bytes // The value is "0xFF+'SMB'".
            public byte Command;
            public SMB_ERROR Status;
            public byte Flags;
            public ushort Flags2;  //Here there are 14 bytes of data which is used differently among different dialects.
            public ushort PIDHigh;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)] public byte[] SecurityFeatures; // size 8 bytes a signature in SMB_COM_NEGOTITATE it's 0's
            public ushort Reserved;
            public ushort TID; // A tree identifier
            public ushort PIDLow;
            public ushort UID;
            public ushort MID;
            public SMB1_HEADER(byte command, byte flags, ushort flags2)
            {
                Protocol = new byte[] { 0xFF, 0x53, 0x4D, 0x42 };
                Command = command;
                Status = new SMB_ERROR(0x00);
                Flags = flags;
                Flags2 = flags2;
                PIDHigh = 0x00;
                SecurityFeatures = new byte[] { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
                Reserved = 0x0000;
                Random random = new Random();
                PIDLow = (ushort)random.Next(1 << 16);
                TID = 0x0000;
                UID = 0x0000;
                MID = 0x0001;

            }
        }

        // Reference https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-cifs/25c8c3c9-58fc-4bb8-aa8f-0272dede84c5

        public struct SMB_PARAMETERS
        {
            public byte WordCount;

            public SMB_PARAMETERS(byte wordCount)
            {
                WordCount = wordCount;
            }
        }

        public struct SMB_DATA
        {
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)] public byte[] BytesCount;

            public SMB_DATA(byte[] bytesCount)
            {
                BytesCount = bytesCount;
            }
        }
        public struct Dialect
        {
            public byte BufferFormat;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 10)] public byte[] Name;

            public Dialect(byte[] name)
            {
                BufferFormat = 0x02;
                Name = name;
            }
        }

        public struct NetBIOS
        {
            public byte MessageType;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 3)] public byte[] Size; // size 3 bytes

            public NetBIOS(byte[] size)
            {
                MessageType = 0x00;
                Size = size;
            }
        }

        [Flags]
        public enum SecurityMode : byte
        {
            NEGOTIATE_USER_SECURITY = 0x01,
            NEGOTIATE_ENCRYPT_PASSWORDS = 0x02,
            NEGOTIATE_SECURITY_SIGNATURES_ENABLED = 0x04,
            NEGOTIATE_SECURITY_SIGNATURES_REQUIRED = 0x08,
        }


        public struct SMB_NEGOTIATE_RESPONSE
        {
            public byte WordCount;
            public ushort SelectedIndex;
            public SecurityMode SecurityMode;
            public ushort MaxMpxCount;
            public ushort MaxVCs;
            public uint MaxBufferSize; // size 4
            public uint MinBufferSize; // size 4
            public uint SessionKey; // size 4
            public uint Capabilities; // size 4
            public string SystemTime; // size 8
            public ushort ServerTimeZone;
            public byte ChallengeLength;
            public ushort ByteCount;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)] public byte[] ServerGuid;

            public SMB_NEGOTIATE_RESPONSE(ushort selectedIndex)
            {
                WordCount = 0;
                SelectedIndex = selectedIndex;
                SecurityMode = 0;
                MaxMpxCount = 0;
                MaxVCs = 0;
                MaxBufferSize = 0;
                MinBufferSize = 0;
                SessionKey = 0;
                Capabilities = 0;
                SystemTime = "00000000";
                ServerTimeZone = 0;
                ChallengeLength = 0;
                ByteCount = 0;
                ServerGuid = new byte[] { 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36 };
            }

        }

        public struct SMB2_HEADER
        {

            // Always 64 bytes

            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)] public byte[] ProtocolID;
            public ushort HeaderLength;
            public ushort CreditCharge;
            public ushort ChanngelSequence;
            public ushort Reserved;
            public ushort Command;
            public ushort CreditsRequested;
            public uint Flags;
            public uint ChainOffest;
            public ulong MessageID;
            public uint PID;
            public uint TreeID;
            public ulong SessionID;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)] public byte[] Signature;

            public SMB2_HEADER(ushort command, uint flags)
            {
                ProtocolID = new byte[] { 0xFE, 0x53, 0x4D, 0x42 };
                HeaderLength = 64;
                CreditCharge = 0;
                ChanngelSequence = 0;
                Reserved = 0;
                Command = command;
                CreditsRequested = 0;
                Flags = flags;
                ChainOffest = 0;
                MessageID = 0;
                PID = 0;
                TreeID = 0;
                SessionID = 0;
                Signature = new byte[] { 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36 };
            }

        }

        public struct SMB2_NEGOTIATE_REQUEST
        {
            public ushort StructureSize;
            public ushort DialectCount;
            public ushort SecurityMode;
            public ushort Resereved;
            public uint Capabilities;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)] public byte[] ClientGUID;
            public uint NegotiateContextOffset;
            public ushort NegotiateContextCount;
            public ushort Reserved2;

            public SMB2_NEGOTIATE_REQUEST(ushort dialectCount)
            {
                StructureSize = 36;
                DialectCount = dialectCount;
                SecurityMode = 0;
                Resereved = 0;
                Capabilities = 0;
                ClientGUID = new byte[] { 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36 };
                NegotiateContextOffset = 0;
                NegotiateContextCount = 0;
                Reserved2 = 0;

            }

        }

        public struct SMB2_Dialect
        {
            public ushort Dialect;

            public SMB2_Dialect(ushort dialect)
            {
                Dialect = dialect;
            }
        }

        [Flags]
        public enum SecurityModeSMB2 : ushort
        {
            SMB2_NEGOTIATE_SIGNING_ENABLED = 0x0001,
            SMB2_NEGOTIATE_SIGNING_REQUIRED = 0x0002,
        }

        public struct SMB2_NEGOTIATE_RESPONSE
        {
            public ushort StructureSize;
            public SecurityModeSMB2 SecurityMode;
            public ushort DialectRevision;
            public ushort NegotiateContextCount;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)] public byte[] ServerGuid;
            public uint Capabilities;
            public uint MaxTransactSize;
            public uint MaxReadSize;
            public uint MaxWriteSize;
            public ulong SystemTime;
            public ulong ServerStartTime;
            public ushort SecurityBufferOffset;
            public ushort SecurityBufferLength;
            public uint NegotiateContextOffset;

            public SMB2_NEGOTIATE_RESPONSE(ushort structureSize)
            {
                StructureSize = 0;
                SecurityMode = 0;
                DialectRevision = 0;
                ServerGuid = new byte[] { 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36 };
                Capabilities = 0;
                MaxTransactSize = 0;
                MaxReadSize = 0;
                MaxWriteSize = 0;
                SystemTime = 0;
                ServerStartTime = 0;
                SecurityBufferOffset = 0;
                SecurityBufferLength = 0;
                NegotiateContextCount = 0;
                NegotiateContextOffset = 0;
            }

        }
        public static byte[] getBytes<T>(T header)
        {

            int size = Marshal.SizeOf(header);
            byte[] arr = new byte[size];

            IntPtr ptr = Marshal.AllocHGlobal(size);
            Marshal.StructureToPtr(header, ptr, true);
            Marshal.Copy(ptr, arr, 0, size);
            Marshal.FreeHGlobal(ptr);
            return arr;
        }
        public static byte[] Combine(byte[] first, byte[] second)
        {
            byte[] ret = new byte[first.Length + second.Length];
            Buffer.BlockCopy(first, 0, ret, 0, first.Length);
            Buffer.BlockCopy(second, 0, ret, first.Length, second.Length);
            return ret;
        }

        public static string BytesCountFromBytes(byte[] bytes_array)
        {
            int decimal_size = bytes_array.Length;
            return String.Format("{0:X2}", decimal_size);
        }

        public static byte[] HexStringToByteArray(string hex)
        {
            return Enumerable.Range(0, hex.Length)
                             .Where(x => x % 2 == 0)
                             .Select(x => Convert.ToByte(hex.Substring(x, 2), 16))
                             .ToArray();
        }
        public static byte[] BuildSMBNegotitateRequest()
        {
            byte[] trailing = { 0x00 };
            byte[] trailing2 = { 0x00, 0x00 };

            SMB1_HEADER SMBh = new SMB1_HEADER(0x72, 0x18, 0x6845);

            byte[] dialectNTBytes = { 0x4e, 0x54, 0x20, 0x4c, 0x4d, 0x20, 0x30, 0x2e, 0x31, 0x32 };
            Dialect dialect = new Dialect(dialectNTBytes);
            byte[] dialectSize = Combine(HexStringToByteArray(BytesCountFromBytes(getBytes(dialect))), trailing);

            SMB_DATA dialects = new SMB_DATA(dialectSize);
            SMB_PARAMETERS smbParameters = new SMB_PARAMETERS(0x00);
            byte[] negotiateProtocolRequest = Combine(getBytes(smbParameters), Combine(getBytes(dialects), Combine(getBytes(dialect), trailing)));
            byte[] smbRequest = Combine(getBytes(SMBh), negotiateProtocolRequest);
            byte[] sizeOfRequest = Combine(trailing2, HexStringToByteArray(BytesCountFromBytes(smbRequest)));

            NetBIOS netBiosh = new NetBIOS(sizeOfRequest);

            byte[] bytesToSend = Combine(getBytes(netBiosh), smbRequest);

            return bytesToSend;

        }
        public static byte[] BuildSMB2NegotitateRequest()
        {
            byte[] trailing2 = { 0x00, 0x00 };

            SMB2_HEADER SMBh = new SMB2_HEADER(0, 0);

            SMB2_Dialect dialect1 = new SMB2_Dialect(0x0202);
            SMB2_Dialect dialect2 = new SMB2_Dialect(0x0210);
            SMB2_Dialect dialect3 = new SMB2_Dialect(0x0300);
            SMB2_Dialect dialect4 = new SMB2_Dialect(0x0302);


            byte[] dialectesBytes = Combine(getBytes(dialect1), Combine(getBytes(dialect2), Combine(getBytes(dialect3), getBytes(dialect4))));
            SMB2_NEGOTIATE_REQUEST negotiateRequest = new SMB2_NEGOTIATE_REQUEST(4);
            byte[] negotiateRequestBytes = Combine(getBytes(negotiateRequest), dialectesBytes);
            byte[] smbRequest = Combine(getBytes(SMBh), negotiateRequestBytes);


            byte[] sizeOfRequest = Combine(trailing2, HexStringToByteArray(BytesCountFromBytes(smbRequest)));

            NetBIOS netBiosh = new NetBIOS(sizeOfRequest);


            byte[] bytesToSend = Combine(getBytes(netBiosh), smbRequest);


            return bytesToSend;

        }
        public static byte ReadByte(byte[] buffer, int offset)
        {
            return buffer[offset];
        }

        public static byte[] ReadBytes(byte[] buffer, int offset, int length)
        {
            byte[] result = new byte[length];
            Array.Copy(buffer, offset, result, 0, length);
            return result;
        }

        public static bool GetIfSecurityModeSMB1(byte[] bytesReceived)
        {

            SMB_NEGOTIATE_RESPONSE smbResponse = new SMB_NEGOTIATE_RESPONSE(0);

            smbResponse.SecurityMode = (SecurityMode)ReadByte(bytesReceived, 39);

            if ((smbResponse.SecurityMode & SecurityMode.NEGOTIATE_SECURITY_SIGNATURES_REQUIRED) == SecurityMode.NEGOTIATE_SECURITY_SIGNATURES_REQUIRED)
            {
                return true;
            }

            return false;
        }

        public static bool GetIfSecurityModeSMB2(byte[] bytesReceived)
        {
            SMB2_NEGOTIATE_RESPONSE smbResponse = new SMB2_NEGOTIATE_RESPONSE();
            smbResponse.SecurityMode = (SecurityModeSMB2)ReadByte(bytesReceived, 70);

            if ((smbResponse.SecurityMode & SecurityModeSMB2.SMB2_NEGOTIATE_SIGNING_REQUIRED) == SecurityModeSMB2.SMB2_NEGOTIATE_SIGNING_REQUIRED)
            {
                return true;
            }
            return false;
        }
        public static Socket ConnectSocketNew(string server, int port)
        {
            Socket s = null;
            IPHostEntry hostEntry = null;

            // Get host related information.
            hostEntry = Dns.GetHostEntry(server);

            foreach (IPAddress address in hostEntry.AddressList)
            {
                IPEndPoint ipe = new IPEndPoint(address, port);
                Socket tempSocket =
                    new Socket(ipe.AddressFamily, SocketType.Stream, ProtocolType.Tcp);

                tempSocket.Connect(ipe);

                if (tempSocket.Connected)
                {
                    s = tempSocket;
                    break;
                }
                else
                {
                    continue;
                }
            }
            return s;
        }

        public static string ByteArrayToString(byte[] ba)
        {
            StringBuilder hex = new StringBuilder(ba.Length * 2);
            foreach (byte b in ba)
                hex.AppendFormat("{0:x2}", b);
            return hex.ToString();
        }

        public enum SMBVersionType
        {
            SMB1_PROTOCOL,
            SMB2_PROTOCOL,
            VERSION_VALIDATION_FAILED

        }
        public static SMBVersionType CheckAndValidateResponseVersion(byte [] bytesReceived)
        {
            byte [] SMB1_SIGNATURE = new byte[] { 0xFF, 0x53, 0x4D, 0x42 };
            byte [] SMB2_SIGNATURE = new byte[] { 0xFE, 0x53, 0x4D, 0x42 };

            byte [] ProtocolID = ReadBytes(bytesReceived, 4, 4);

            if (SMB1_SIGNATURE.SequenceEqual(ProtocolID))
                return SMBVersionType.SMB1_PROTOCOL;

            if (SMB2_SIGNATURE.SequenceEqual(ProtocolID))
                return SMBVersionType.SMB2_PROTOCOL;

            return SMBVersionType.VERSION_VALIDATION_FAILED;
        }
        public static string CheckInternal(string server, int port)
        {
            SMBVersionType version = SMBVersionType.VERSION_VALIDATION_FAILED;
            int bytes = 0;
            try
            {

                Byte[] bytesSentSMB1 = BuildSMBNegotitateRequest();
                Byte[] bytesReceivedSMB1 = new Byte[512];
                using (Socket socket = ConnectSocketNew(server, port))
                {
                    if (socket == null)
                    {
                        return "Unreachable";
                    }
                    else
                    {
                        socket.ReceiveTimeout = 3000;
                    }


                    socket.Send(bytesSentSMB1, bytesSentSMB1.Length, 0);

                    bytes = socket.Receive(bytesReceivedSMB1, bytesReceivedSMB1.Length, 0);

                    version = CheckAndValidateResponseVersion(bytesReceivedSMB1);
                    if (version == SMBVersionType.SMB1_PROTOCOL)
                    {
                        bool signinigRequired = GetIfSecurityModeSMB1(bytesReceivedSMB1);
                        return signinigRequired.ToString();
                    }
                    socket.Close();
                }
            }
            catch
            {
                if (bytes == 0)
                {
                    version = SMBVersionType.SMB2_PROTOCOL;
                }


            }
            if (version == SMBVersionType.SMB2_PROTOCOL)
            {
                try
                {
                    Byte[] bytesSentSMB2 = BuildSMB2NegotitateRequest();
                    Byte[] bytesReceivedSMB2 = new Byte[512];
                    using (Socket socket = ConnectSocketNew(server, port))
                    {
                        if (socket == null)
                        {
                            return "Unreachable";
                        }
                        else
                        {
                            socket.ReceiveTimeout = 3000;
                        }

                        socket.Send(bytesSentSMB2, bytesSentSMB2.Length, 0);

                        bytes = 0;

                        bytes = socket.Receive(bytesReceivedSMB2, bytesReceivedSMB2.Length, 0);

                        version = CheckAndValidateResponseVersion(bytesReceivedSMB2);
                        if (version == SMBVersionType.SMB2_PROTOCOL)
                        {
                            bool signinigRequired = GetIfSecurityModeSMB2(bytesReceivedSMB2);
                            return signinigRequired.ToString();
                        }
                        socket.Close();
                    }
                }
                catch
                {
                    return "Unreachable";
                }
            }
            return "Unrechable";

        }

        public static string[] ResultFromCheckInternal(string host, int port, string DN)
        {
            string[] resultsArray = new string[3];
            resultsArray[0] = host;
            resultsArray[1] = DN;
            resultsArray[2] = CheckInternal(host, port);

            return resultsArray;

        }

        public static Task<string[]> Check(string host, string DN)
        {
            int port = 445;

            return Task.Run(() => ResultFromCheckInternal(host, port, DN));
        }

    }
}

"@

if (-not ('SmbSigning.SmbSigningChecking' -as [Type])) {
    Add-Type $code
}

# Script Global Variables
$outputObjects = [System.Collections.ArrayList]@()
$domainControllersFailedCount = 0

try {
    if ($PSBoundParameters['ForestName'] -and $PSBoundParameters['DomainNames']) {
        $ForestName = $ForestName.ToLower()
        $DomainNames = ConvertTo-Lowercase -DomainNames $DomainNames
    }
    $outputObjects = [System.Collections.ArrayList]@()
    $res = New-Result

    $dcs = @()
    $unavailableDomains = [System.Collections.ArrayList]@()
    foreach ($domain in $DomainNames) {
        if (-not (Confirm-DomainAvailability $domain)) {
            [void]$unavailableDomains.Add($domain)
            continue
        }
        $DN = Get-DN $domain

        $searchFilter = "(&(objectCategory=computer)(primaryGroupID=516))"
        $attributes = @("dnshostname","serverreferencebl")

        $searchParams = @{
            dnsDomain = $domain
            attributes = $attributes
            baseDN = $DN
            scope = "SubTree"
            filter = $searchFilter
        }

        $dcs += Search-AD @searchParams
    }

    $tasks = @()

    foreach ($dc in $dcs) {
        if ($dc.attributes.serverreferencebl) {
            $nTDSDSADN = 'CN=NTDS Settings,' + $dc.attributes.serverreferencebl.GetValues("string")[0]

            $forestDN = Get-DN -dnsDomain $forestName
            $configDN = "CN=Configuration,$forestDN"

            $searchParams = @{
                dnsDomain = $ForestName
                attributes = "objectguid"
                baseDN = $configDN
                scope = "SubTree"
                filter = "DistinguishedName=$nTDSDSADN"
            }

            $nTDSDSA = Search-AD @searchParams

            if ($nTDSDSA) {
                $nTDSDSAGuid = (New-Object Guid @(,$nTDSDSA.attributes."objectguid"[0])).Guid
            }
            else {
                continue
            }
        }
        else {
            continue
        }

        $dcHostName = $dc.Attributes.dnshostname[$GET_STRING]
        $tasks += [SmbSigning.SmbSigningChecking]::Check($dcHostName, $dc.DistinguishedName)
    }
    [System.Threading.Tasks.Task]::WhenAll($tasks).Wait()
    $unreachables = 0

    foreach ($result in $tasks) {
        $resultsArray = $result.Result
        $isSMBSigningRequired = $resultsArray[2];
        $dcDN = $resultsArray[1]
        $hostName = $resultsArray[0]

        if ($isSMBSigningRequired -eq "False") {
            $domainControllersFailedCount++
            $thisOutput = [PSCustomObject][Ordered] @{
                DistinguishedName=$dcDN
                HostName = $hostName
                State = "SMB Signing is not required"
            }
            [void]$outputObjects.Add($thisOutput)
        }
        elseif ($isSMBSigningRequired -eq "Unreachable") {
            $domainControllersFailedCount++
            $unreachables++
            $thisOutput = [PSCustomObject][Ordered] @{
                DistinguishedName = $dcDN
                HostName = $hostName
                State = "Unreachable"
            }
            [void]$outputObjects.Add($thisOutput)
        }
    }

    if ($outputObjects) {
        $configArgs = @{
            ScriptName = $self.ScriptName
            Path = $MyInvocation.MyCommand.ScriptBlock.File
            Fields = $outputObjects[0]
        }
        $config = Resolve-Configuration @configArgs
        $outputObjects | Set-IgnoredFlag -Configuration $config
        $scoreOutput = $outputObjects | Get-Score -Impact $self.Impact
        if ($scoreOutput.Score -lt 100) {
            if ($unreachables -eq 0) {
                $res.ResultObjects = $outputObjects
                $res.ResultMessage = "Found $($domainControllersFailedCount) DCs that do not require SMB Signing."
                $res.Remediation = $self.Remediation
                $res.Status = 'Failed'
                $res.Score = $scoreOutput.Score
            }
            else {
                $res.ResultObjects = $outputObjects
                $res.ResultMessage = "Found $($domainControllersFailedCount-$unreachables) DCs that do not require SMB Signing, And $($unreachables) DCs are Unreachable."
                $res.Remediation = $self.Remediation
                $res.Status = 'Failed'
                $res.Score = $scoreOutput.Score
            }
        }

        if ($scoreOutput.Ignoredcount -gt 0) {
            $res.ResultMessage += " ($($scoreOutput.Ignoredcount) Objects ignored)."
            $res.ResultObjects = $outputObjects
        }

        $badObjectCount = $outputObjects.Count - $scoreOutput.Ignoredcount
        if ($badObjectCount -eq 0) {
            $res.ResultObjects = $outputObjects
            $res.Remediation = $self.Remediation
            $res.Status = 'Pass'
            $res.Score = $scoreOutput.Score
        }
        elseif ($unreachables -ge $badObjectCount) {
            $res.ResultObjects = $outputObjects
            $res.ResultMessage = "There are {0} DCs that are unreachable." -f $unreachables
            $res.Remediation = $self.Remediation
            $res.Status = 'Error'
        }
    }

    # deal with unavailable domains
    if ($unavailableDomains.Count -gt 0) {
        if ($unavailableDomains.Count -eq $DomainNames.Count) {
            $res.Score = 0
            $res.Status = 'Error'
            $res.ResultMessage = "The following domains were unavailable: $($unavailableDomains -join ', ')."
            $res.Remediation = "None"
        }
        else {
            $res.ResultMessage += " The following domains were unavailable: $($unavailableDomains -join ', ')."
        }
    }
}
catch {
    return ConvertTo-ErrorResult $_
}
return $res

# SIG # Begin signature block
# MIIuIwYJKoZIhvcNAQcCoIIuFDCCLhACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC9TBUsMBRVXBYh
# A3rNgUWqn1Ml0a8dUkGudCnw95jPG6CCE6MwggVyMIIDWqADAgECAhB2U/6sdUZI
# k/Xl10pIOk74MA0GCSqGSIb3DQEBDAUAMFMxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSkwJwYDVQQDEyBHbG9iYWxTaWduIENvZGUgU2ln
# bmluZyBSb290IFI0NTAeFw0yMDAzMTgwMDAwMDBaFw00NTAzMTgwMDAwMDBaMFMx
# CzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSkwJwYDVQQD
# EyBHbG9iYWxTaWduIENvZGUgU2lnbmluZyBSb290IFI0NTCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBALYtxTDdeuirkD0DcrA6S5kWYbLl/6VnHTcc5X7s
# k4OqhPWjQ5uYRYq4Y1ddmwCIBCXp+GiSS4LYS8lKA/Oof2qPimEnvaFE0P31PyLC
# o0+RjbMFsiiCkV37WYgFC5cGwpj4LKczJO5QOkHM8KCwex1N0qhYOJbp3/kbkbuL
# ECzSx0Mdogl0oYCve+YzCgxZa4689Ktal3t/rlX7hPCA/oRM1+K6vcR1oW+9YRB0
# RLKYB+J0q/9o3GwmPukf5eAEh60w0wyNA3xVuBZwXCR4ICXrZ2eIq7pONJhrcBHe
# OMrUvqHAnOHfHgIB2DvhZ0OEts/8dLcvhKO/ugk3PWdssUVcGWGrQYP1rB3rdw1G
# R3POv72Vle2dK4gQ/vpY6KdX4bPPqFrpByWbEsSegHI9k9yMlN87ROYmgPzSwwPw
# jAzSRdYu54+YnuYE7kJuZ35CFnFi5wT5YMZkobacgSFOK8ZtaJSGxpl0c2cxepHy
# 1Ix5bnymu35Gb03FhRIrz5oiRAiohTfOB2FXBhcSJMDEMXOhmDVXR34QOkXZLaRR
# kJipoAc3xGUaqhxrFnf3p5fsPxkwmW8x++pAsufSxPrJ0PBQdnRZ+o1tFzK++Ol+
# A/Tnh3Wa1EqRLIUDEwIrQoDyiWo2z8hMoM6e+MuNrRan097VmxinxpI68YJj8S4O
# JGTfAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
# A1UdDgQWBBQfAL9GgAr8eDm3pbRD2VZQu86WOzANBgkqhkiG9w0BAQwFAAOCAgEA
# Xiu6dJc0RF92SChAhJPuAW7pobPWgCXme+S8CZE9D/x2rdfUMCC7j2DQkdYc8pzv
# eBorlDICwSSWUlIC0PPR/PKbOW6Z4R+OQ0F9mh5byV2ahPwm5ofzdHImraQb2T07
# alKgPAkeLx57szO0Rcf3rLGvk2Ctdq64shV464Nq6//bRqsk5e4C+pAfWcAvXda3
# XaRcELdyU/hBTsz6eBolSsr+hWJDYcO0N6qB0vTWOg+9jVl+MEfeK2vnIVAzX9Rn
# m9S4Z588J5kD/4VDjnMSyiDN6GHVsWbcF9Y5bQ/bzyM3oYKJThxrP9agzaoHnT5C
# JqrXDO76R78aUn7RdYHTyYpiF21PiKAhoCY+r23ZYjAf6Zgorm6N1Y5McmaTgI0q
# 41XHYGeQQlZcIlEPs9xOOe5N3dkdeBBUO27Ql28DtR6yI3PGErKaZND8lYUkqP/f
# obDckUCu3wkzq7ndkrfxzJF0O2nrZ5cbkL/nx6BvcbtXv7ePWu16QGoWzYCELS/h
# AtQklEOzFfwMKxv9cW/8y7x1Fzpeg9LJsy8b1ZyNf1T+fn7kVqOHp53hWVKUQY9t
# W76GlZr/GnbdQNJRSnC0HzNjI3c/7CceWeQIh+00gkoPP/6gHcH1Z3NFhnj0qinp
# J4fGGdvGExTDOUmHTaCX4GUT9Z13Vunas1jHOvLAzYIwggbmMIIEzqADAgECAhB3
# vQ4DobcI+FSrBnIQ2QRHMA0GCSqGSIb3DQEBCwUAMFMxCzAJBgNVBAYTAkJFMRkw
# FwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSkwJwYDVQQDEyBHbG9iYWxTaWduIENv
# ZGUgU2lnbmluZyBSb290IFI0NTAeFw0yMDA3MjgwMDAwMDBaFw0zMDA3MjgwMDAw
# MDBaMFkxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMS8w
# LQYDVQQDEyZHbG9iYWxTaWduIEdDQyBSNDUgQ29kZVNpZ25pbmcgQ0EgMjAyMDCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANZCTfnjT8Yj9GwdgaYw90g9
# z9DljeUgIpYHRDVdBs8PHXBg5iZU+lMjYAKoXwIC947Jbj2peAW9jvVPGSSZfM8R
# Fpsfe2vSo3toZXer2LEsP9NyBjJcW6xQZywlTVYGNvzBYkx9fYYWlZpdVLpQ0LB/
# okQZ6dZubD4Twp8R1F80W1FoMWMK+FvQ3rpZXzGviWg4QD4I6FNnTmO2IY7v3Y2F
# QVWeHLw33JWgxHGnHxulSW4KIFl+iaNYFZcAJWnf3sJqUGVOU/troZ8YHooOX1Re
# veBbz/IMBNLeCKEQJvey83ouwo6WwT/Opdr0WSiMN2WhMZYLjqR2dxVJhGaCJedD
# CndSsZlRQv+hst2c0twY2cGGqUAdQZdihryo/6LHYxcG/WZ6NpQBIIl4H5D0e6lS
# TmpPVAYqgK+ex1BC+mUK4wH0sW6sDqjjgRmoOMieAyiGpHSnR5V+cloqexVqHMRp
# 5rC+QBmZy9J9VU4inBDgoVvDsy56i8Te8UsfjCh5MEV/bBO2PSz/LUqKKuwoDy3K
# 1JyYikptWjYsL9+6y+JBSgh3GIitNWGUEvOkcuvuNp6nUSeRPPeiGsz8h+WX4VGH
# aekizIPAtw9FbAfhQ0/UjErOz2OxtaQQevkNDCiwazT+IWgnb+z4+iaEW3VCzYkm
# eVmda6tjcWKQJQ0IIPH/AgMBAAGjggGuMIIBqjAOBgNVHQ8BAf8EBAMCAYYwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQU
# 2rONwCSQo2t30wygWd0hZ2R2C3gwHwYDVR0jBBgwFoAUHwC/RoAK/Hg5t6W0Q9lW
# ULvOljswgZMGCCsGAQUFBwEBBIGGMIGDMDkGCCsGAQUFBzABhi1odHRwOi8vb2Nz
# cC5nbG9iYWxzaWduLmNvbS9jb2Rlc2lnbmluZ3Jvb3RyNDUwRgYIKwYBBQUHMAKG
# Omh0dHA6Ly9zZWN1cmUuZ2xvYmFsc2lnbi5jb20vY2FjZXJ0L2NvZGVzaWduaW5n
# cm9vdHI0NS5jcnQwQQYDVR0fBDowODA2oDSgMoYwaHR0cDovL2NybC5nbG9iYWxz
# aWduLmNvbS9jb2Rlc2lnbmluZ3Jvb3RyNDUuY3JsMFYGA1UdIARPME0wQQYJKwYB
# BAGgMgEyMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29t
# L3JlcG9zaXRvcnkvMAgGBmeBDAEEATANBgkqhkiG9w0BAQsFAAOCAgEACIhyJsav
# +qxfBsCqjJDa0LLAopf/bhMyFlT9PvQwEZ+PmPmbUt3yohbu2XiVppp8YbgEtfjr
# y/RhETP2ZSW3EUKL2Glux/+VtIFDqX6uv4LWTcwRo4NxahBeGQWn52x/VvSoXMNO
# Ca1Za7j5fqUuuPzeDsKg+7AE1BMbxyepuaotMTvPRkyd60zsvC6c8YejfzhpX0FA
# Z/ZTfepB7449+6nUEThG3zzr9s0ivRPN8OHm5TOgvjzkeNUbzCDyMHOwIhz2hNab
# XAAC4ShSS/8SS0Dq7rAaBgaehObn8NuERvtz2StCtslXNMcWwKbrIbmqDvf+28rr
# vBfLuGfr4z5P26mUhmRVyQkKwNkEcUoRS1pkw7x4eK1MRyZlB5nVzTZgoTNTs/Z7
# KtWJQDxxpav4mVn945uSS90FvQsMeAYrz1PYvRKaWyeGhT+RvuB4gHNU36cdZytq
# tq5NiYAkCFJwUPMB/0SuL5rg4UkI4eFb1zjRngqKnZQnm8qjudviNmrjb7lYYuA2
# eDYB+sGniXomU6Ncu9Ky64rLYwgv/h7zViniNZvY/+mlvW1LWSyJLC9Su7UpkNpD
# R7xy3bzZv4DB3LCrtEsdWDY3ZOub4YUXmimi/eYI0pL/oPh84emn0TCOXyZQK8ei
# 4pd3iu/YTT4m65lAYPM8Zwy2CHIpNVOBNNwwggc/MIIFJ6ADAgECAgxsjPy20SAh
# 5jGEkUUwDQYJKoZIhvcNAQELBQAwWTELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEds
# b2JhbFNpZ24gbnYtc2ExLzAtBgNVBAMTJkdsb2JhbFNpZ24gR0NDIFI0NSBDb2Rl
# U2lnbmluZyBDQSAyMDIwMB4XDTI0MDYwNDEzMDU0NVoXDTI3MDcxNTE0MzA0NFow
# gYoxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5MRAwDgYDVQQHEwdI
# b2Jva2VuMRYwFAYDVQQKEw1TRU1QRVJJUyBJTkMuMRYwFAYDVQQDEw1TRU1QRVJJ
# UyBJTkMuMSQwIgYJKoZIhvcNAQkBFhVjb2Rlc2lnbkBzZW1wZXJpcy5jb20wggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCNYiocFDfmQmq3ngxGCT305SbM
# YRrXTVpotaqQbcpoesQbYwj/Wq94RNeh7cAXSLaMaQt5YlyhAO/aND5VxLBiWi9+
# Y2v8cGziq1XGTGSFV6Rwc0Go777qQP0lc76Q8qGijZNWqIWWSaE3cS57dIFwNAWn
# pWVtUhtfz3LJZ1ok7vP+UQT8zC5qfbM7pAxJ8T6vrsInAG5iClrwuspeuUmAaLbW
# MKHFn2yeLOXAbEqVSwn8R8gNUBVVSMkXKooXDU35fr5xGRBuSVtdnguHL7jAPuDu
# 5btcOggLcCgD9fegjXQeKphZVdpdRchpXe3idFYHAVx21552cFfshEHL4M4I3YcO
# C/5JJcyLMIHP63MXPzQbbZ3IZQ9++sIZora75v7Bynx04xl/2mO5Y2LGiu4DHs6r
# xgBYU8AnA5ncM/mcrEoG/Ce03z7nt7Mnl7KC3GjYBnx5XCwYc0sLr6sHLKJdsd3b
# jwL/watiUxV60+lW+t5Z1JYQGlBjHwMEfQYliZHMix2Pe+9KsMbkvLeHMGo31pUZ
# qeBl7hEPCD0x5KqP4VrBNPySHDhJMk582TvJdoHCKZYfJHdkChHzADIbvUcAE69b
# TFsTOp/ypC/yOTFrZFuBr6w30+x+9UVy4+jsx1MUoNBOLv6on1MmYaTH5sp4/MoA
# 6LkPG0h7ZJUq2qlNXwIDAQABo4IB0zCCAc8wDgYDVR0PAQH/BAQDAgeAMIGbBggr
# BgEFBQcBAQSBjjCBizBKBggrBgEFBQcwAoY+aHR0cDovL3NlY3VyZS5nbG9iYWxz
# aWduLmNvbS9jYWNlcnQvZ3NnY2NyNDVjb2Rlc2lnbmNhMjAyMC5jcnQwPQYIKwYB
# BQUHMAGGMWh0dHA6Ly9vY3NwLmdsb2JhbHNpZ24uY29tL2dzZ2NjcjQ1Y29kZXNp
# Z25jYTIwMjAwVgYDVR0gBE8wTTBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYm
# aHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCAYGZ4EMAQQB
# MAkGA1UdEwQCMAAwRQYDVR0fBD4wPDA6oDigNoY0aHR0cDovL2NybC5nbG9iYWxz
# aWduLmNvbS9nc2djY3I0NWNvZGVzaWduY2EyMDIwLmNybDAgBgNVHREEGTAXgRVj
# b2Rlc2lnbkBzZW1wZXJpcy5jb20wEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0j
# BBgwFoAU2rONwCSQo2t30wygWd0hZ2R2C3gwHQYDVR0OBBYEFD9AijmjNjU3CNw8
# Unvu8bt4SgXDMA0GCSqGSIb3DQEBCwUAA4ICAQAQD+KrgTxd7wyLivnLriAHzIjT
# tvC5k8ov1rWGJgajZsA3MWQJ91mRkZzpDGYdrXgoX0f8D3qxpujkPOOsq8z8+AlM
# 957IzpDoq6oqLapaw25ADPTsPhlSxzY49Y9/B6pLOMVwCCTjGXDlDwtHiJHEyUkV
# 0icoXCxmSGSzT4fA8HHSDRf5xd1FTFtZ2CZFf40VN9ZjNXeNs602dI9t4LtsXY8Y
# 6g+wxEKc9Iwhuitp+gdXnDQ312nKo3p8Hsx5TGwRTkPJNCNq+BYtba7Z7fu9m3lo
# wjm3SaRfxgkZhW4//V8licRnrsMA3U2X4SkuXCMlC9t3NITiSPq5uEyhqhueu7wZ
# bOo6hr3+2j7Y5sDrHQ0g6GpvillfX+aiDuMwx1Oo+CmJezn7UIE8kFC934D8QEH/
# veD9GtVY1YOa4pXnn6d1Kd1tPPG4R5OXrjiRmwIU9c1UVR84t86meuqt+dOJo7L2
# i1RaNdcPLOExrzHZGZEUSZaizZxBN+XKWXDHWShq0zA+llH59l/RIbVZRUqt6c1M
# D/egPtsm0XGJABzhioGtjSmALmJiv4XWXg77pyhuy1SXELjOAW9WgLLv4xQaO4Fi
# XHO/yqLwh+XawyLk+iKLx3Gch3nGR8MepeRfqTg85PthgPQklS5FVN+q9Y6t3yR/
# sUxkJCMAt0B9E7sFVDGCGdYwghnSAgEBMGkwWTELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExLzAtBgNVBAMTJkdsb2JhbFNpZ24gR0NDIFI0
# NSBDb2RlU2lnbmluZyBDQSAyMDIwAgxsjPy20SAh5jGEkUUwDQYJYIZIAWUDBAIB
# BQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG
# 9w0BCQQxIgQgzYrvNDtI8S4YWLpTjRipt5Z0d+jfuqVkt0g8eoWnzg8wDQYJKoZI
# hvcNAQEBBQAEggIATfbu2F0TXHnMXlW16Csq0OMqcJRg9b7RLyWYgRUFmNrkBpnZ
# Auk9GStDGBSx1jsg0IsFysqtyOK4oRubRvnhbqPAXjrT5DorZRcsDWPwIiUTCg2i
# 6gHMt3+8eujL/uqIZsQziPmvh/b95bUav2tM0l13BVBo5s95mKUjdpFxk88uRVY5
# kzpCB8VQvf9AyuulSCbkotOqNEfXb7DF4S16bSXWOHn47bYaEXoPl6Rbq+kgcDAW
# gpdb6RoAfhowg3dYtHwCW1WwyQxhy8AY0CndooFfKM1dGMbKOhgRqrMx6PxUmSyF
# jF1OJNLwaV34zs4g8An1NXwe3TLt0tDqb4UjpGYPSi9GN0qEs+n7rsZCGPEU0E+V
# pn5bOmPbpKyo81d9rbaqE6heaLFPWxSoCpryiUczgtpzHlLcfgZCFOH4/847U4tW
# qDfilb5uZIsvWCdAI/yiwzg6EnfQg2TewEQsKNs4Bd5nGDs+JyQZB35Wo1/VhuvF
# 2HUZr3KlO2Nj9JrE9MSp9XMBvf2ESpH4UnOKdI3adVtygMNZ2P1oiuwgSDrVVLiB
# 3M4DG2o+1eV23fCZzOsXi+4iE1KhSmOiy3x8OWCbi/FokPKiFvsBbkGSqXz4XAg1
# 5XujQ/rneCAvbykOKohpBiFJNkhGcng8X43isK+hSBt9+lFwC0FpD0nEGgehgha3
# MIIWswYKKwYBBAGCNwMDATGCFqMwghafBgkqhkiG9w0BBwKgghaQMIIWjAIBAzEN
# MAsGCWCGSAFlAwQCATCB3AYLKoZIhvcNAQkQAQSggcwEgckwgcYCAQEGCSsGAQQB
# oDICAzAxMA0GCWCGSAFlAwQCAQUABCCCSSH0aAaHJuES8YcpJxd0wH9Pkh17b31n
# JEqO4E6KXwIUfMOxST+Wtap37vJeTnGan5A96bsYDzIwMjUwNjEwMDc1MjMyWjAD
# AgEBoFekVTBTMQswCQYDVQQGEwJCRTEZMBcGA1UECgwQR2xvYmFsU2lnbiBudi1z
# YTEpMCcGA1UEAwwgR2xvYmFsc2lnbiBUU0EgZm9yIEFkdmFuY2VkIC0gRzSgghJK
# MIIGYjCCBEqgAwIBAgIQAQMy4WW/m3hD4Jl1lGN3CzANBgkqhkiG9w0BAQwFADBb
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTExMC8GA1UE
# AxMoR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBTSEEzODQgLSBHNDAeFw0y
# NTA0MTExNDQ3MDFaFw0zNDEyMTAwMDAwMDBaMFMxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKDBBHbG9iYWxTaWduIG52LXNhMSkwJwYDVQQDDCBHbG9iYWxzaWduIFRTQSBm
# b3IgQWR2YW5jZWQgLSBHNDCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGB
# AL4lejlDGK511tWzocib1iaenoAWN1mu9Ocng7gqw8zEOq8sty7ryNq/wwWveWzX
# NhLatjNeMQ0n8+E9A4EbszvuRGgmnjPkyPUmJS/gkNkDR/QmZV1BxLysCQEhPewZ
# IEYvQB9sZb3VM2W94iCkRMVacCMtRKq2RsqAeeo8vjtsyGm4MgpXSOIJBHM6r4Fz
# KBZy+RsTtzj0Rjg36eklI/nsMLaCIKD+E7dgCl77Yvhvhbx8Gzevdk/vY1H8EQCX
# BZa6JNtfR6DaLDwsh8gxTczI5sRdI3ymYpNov8ymVwBzun3KW4Msk0BMIn25fcxv
# b501hIIfKpnXAZEKzaPQGDDxlkx7PNdUzXw+eF6eVzJYeToLRXOamOHYrSX++ML0
# COvPq2sg/GeXlHL1eMb/UhjKKU0rxtig1sjDMHswGoQYSfS2zNzW1NoeHRFCgS/O
# sJ6VgWLclzFIFpGTzArZiKlu8Zabb+XIO8lAPx9dQU/6AC0MTpVxG9VJrDCQy0oY
# TwIDAQABo4IBqDCCAaQwDgYDVR0PAQH/BAQDAgeAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMB0GA1UdDgQWBBTZN7YzRW6PNQfO96mzCv2gqcj5gjBWBgNVHSAETzBN
# MAgGBmeBDAEEAjBBBgkrBgEEAaAyAR4wNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wDAYDVR0TAQH/BAIwADCBkAYI
# KwYBBQUHAQEEgYMwgYAwOQYIKwYBBQUHMAGGLWh0dHA6Ly9vY3NwLmdsb2JhbHNp
# Z24uY29tL2NhL2dzdHNhY2FzaGEzODRnNDBDBggrBgEFBQcwAoY3aHR0cDovL3Nl
# Y3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3N0c2FjYXNoYTM4NGc0LmNydDAf
# BgNVHSMEGDAWgBTqFsZp5+PLV0U5M6TwQL7Qw71lljBBBgNVHR8EOjA4MDagNKAy
# hjBodHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2NhL2dzdHNhY2FzaGEzODRnNC5j
# cmwwDQYJKoZIhvcNAQEMBQADggIBAGYfzwRhxCcMMGOdFylYezH0PcaS6ABq/E3x
# efhnLFLxh09UMeb2gE/XPDuBDaOR1ArLelpswVILQvkpBswzfheaZ0j/w+cjq/E0
# 3In7HD88F9WRn72NxokSBVMOdpEGqyWdZyeIcv1Db2Eprmb2vIwiuMNes5/frxqD
# Rf2w724UX07LumLYVRNDtH4dIl7qlqyfd+cn3e6s/uWNJGOyF0Yk9U3w6ibkAVmo
# 9W2JqSMRycQ8cC7svE/kuq3GgzscSOZoqzn3MKakNLDjVpu9z7Gh36RrulCrqVFd
# vZDAghLPFiXGxVc+7JyslVqFybbCOkzUvME08bvdxwRjIMDBgPSSQGrhGsKRGdzn
# 9MP3VJ9QpHCuAr29v3n4tGSdo7N53HM+0WBYgmesiKzGajy79/4pROfkamQQzM+i
# ergtga0cNaq9hK8npbrChB0NSA+qBpTxggf0mczlUveZF+IF6IW4+NJxBb2/pUFf
# yfSqg3PR+G3D+gTSkAg/dcS0Dk5f0Jjq0uqkTjA4w0L3qd4FjZNd0sNtATCIIWT7
# FN6nsMSNBtWSPXXmR3U98AfG0/517/SBxiCgAvOWx0hmDTCdpUJfR3vak2OxBlZR
# QxfudAg80Gy8XJ2x5XlbTcBayAHhD2jtm91FdEglFFxSM05mS/AJeDEw29LVZTlR
# sGBMYx6QMIIGWTCCBEGgAwIBAgINAewckkDe/S5AXXxHdDANBgkqhkiG9w0BAQwF
# ADBMMSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3QgQ0EgLSBSNjETMBEGA1UEChMK
# R2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2lnbjAeFw0xODA2MjAwMDAwMDBa
# Fw0zNDEyMTAwMDAwMDBaMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxT
# aWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAt
# IFNIQTM4NCAtIEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA8ALi
# MCP64BvhmnSzr3WDX6lHUsdhOmN8OSN5bXT8MeR0EhmW+s4nYluuB4on7lejxDXt
# szTHrMMM64BmbdEoSsEsu7lw8nKujPeZWl12rr9EqHxBJI6PusVP/zZBq6ct/XhO
# Q4j+kxkX2e4xz7yKO25qxIjw7pf23PMYoEuZHA6HpybhiMmg5ZninvScTD9dW+y2
# 79Jlz0ULVD2xVFMHi5luuFSZiqgxkjvyen38DljfgWrhsGweZYIq1CHHlP5Cljvx
# C7F/f0aYDoc9emXr0VapLr37WD21hfpTmU1bdO1yS6INgjcZDNCr6lrB7w/Vmbk/
# 9E818ZwP0zcTUtklNO2W7/hn6gi+j0l6/5Cx1PcpFdf5DV3Wh0MedMRwKLSAe70q
# m7uE4Q6sbw25tfZtVv6KHQk+JA5nJsf8sg2glLCylMx75mf+pliy1NhBEsFV/W6R
# xbuxTAhLntRCBm8bGNU26mSuzv31BebiZtAOBSGssREGIxnk+wU0ROoIrp1JZxGL
# guWtWoanZv0zAwHemSX5cW7pnF0CTGA8zwKPAf1y7pLxpxLeQhJN7Kkm5XcCrA5X
# DAnRYZ4miPzIsk3bZPBFn7rBP1Sj2HYClWxqjcoiXPYMBOMp+kuwHNM3dITZHWar
# NHOPHn18XpbWPRmwl+qMUJFtr1eGfhA3HWsaFN8CAwEAAaOCASkwggElMA4GA1Ud
# DwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBTqFsZp5+PL
# V0U5M6TwQL7Qw71lljAfBgNVHSMEGDAWgBSubAWjkxPioufi1xzWx/B/yGdToDA+
# BggrBgEFBQcBAQQyMDAwLgYIKwYBBQUHMAGGImh0dHA6Ly9vY3NwMi5nbG9iYWxz
# aWduLmNvbS9yb290cjYwNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5nbG9i
# YWxzaWduLmNvbS9yb290LXI2LmNybDBHBgNVHSAEQDA+MDwGBFUdIAAwNDAyBggr
# BgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8w
# DQYJKoZIhvcNAQEMBQADggIBAH/iiNlXZytCX4GnCQu6xLsoGFbWTL/bGwdwxvsL
# Ca0AOmAzHznGFmsZQEklCB7km/fWpA2PHpbyhqIX3kG/T+G8q83uwCOMxoX+SxUk
# +RhE7B/CpKzQss/swlZlHb1/9t6CyLefYdO1RkiYlwJnehaVSttixtCzAsw0SEVV
# 3ezpSp9eFO1yEHF2cNIPlvPqN1eUkRiv3I2ZOBlYwqmhfqJuFSbqtPl/KufnSGRp
# L9KaoXL29yRLdFp9coY1swJXH4uc/LusTN763lNMg/0SsbZJVU91naxvSsguarnK
# iMMSME6yCHOfXqHWmc7pfUuWLMwWaxjN5Fk3hgks4kXWss1ugnWl2o0et1sviC49
# ffHykTAFnM57fKDFrK9RBvARxx0wxVFWYOh8lT0i49UKJFMnl4D6SIknLHniPOWb
# HuOqhIKJPsBK9SH+YhDtHTD89szqSCd8i3VCf2vL86VrlR8EWDQKie2CUOTRe6jJ
# 5r5IqitV2Y23JSAOG1Gg1GOqg+pscmFKyfpDxMZXxZ22PLCLsLkcMe+97xTYFEBs
# IB3CLegLxo1tjLZx7VIh/j72n585Gq6s0i96ILH0rKod4i0UnfqWah3GPMrz2Ry/
# U02kR1l8lcRDQfkl4iwQfoH5DZSnffK1CfXYYHJAUJUg1ENEvvqglecgWbZ4xqRq
# qiKbMIIFgzCCA2ugAwIBAgIORea7A4Mzw4VlSOb/RVEwDQYJKoZIhvcNAQEMBQAw
# TDEgMB4GA1UECxMXR2xvYmFsU2lnbiBSb290IENBIC0gUjYxEzARBgNVBAoTCkds
# b2JhbFNpZ24xEzARBgNVBAMTCkdsb2JhbFNpZ24wHhcNMTQxMjEwMDAwMDAwWhcN
# MzQxMjEwMDAwMDAwWjBMMSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3QgQ0EgLSBS
# NjETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2lnbjCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJUH6HPKZvnsFMp7PPcNCPG0RQss
# grRIxutbPK6DuEGSMxSkb3/pKszGsIhrxbaJ0cay/xTOURQh7ErdG1rG1ofuTToV
# Bu1kZguSgMpE3nOUTvOniX9PeGMIyBJQbUJmL025eShNUhqKGoC3GYEOfsSKvGRM
# IRxDaNc9PIrFsmbVkJq3MQbFvuJtMgamHvm566qjuL++gmNQ0PAYid/kD3n16qIf
# KtJwLnvnvJO7bVPiSHyMEAc4/2ayd2F+4OqMPKq0pPbzlUoSB239jLKJz9CgYXfI
# WHSw1CM69106yqLbnQneXUQtkPGBzVeS+n68UARjNN9rkxi+azayOeSsJDa38O+2
# HBNXk7besvjihbdzorg1qkXy4J02oW9UivFyVm4uiMVRQkQVlO6jxTiWm05OWgtH
# 8wY2SXcwvHE35absIQh1/OZhFj931dmRl4QKbNQCTXTAFO39OfuD8l4UoQSwC+n+
# 7o/hbguyCLNhZglqsQY6ZZZZwPA1/cnaKI0aEYdwgQqomnUdnjqGBQCe24DWJfnc
# BZ4nWUx2OVvq+aWh2IMP0f/fMBH5hc8zSPXKbWQULHpYT9NLCEnFlWQaYw55PfWz
# jMpYrZxCRXluDocZXFSxZba/jJvcE+kNb7gu3GduyYsRtYQUigAZcIN5kZeR1Bon
# vzceMgfYFGM8KEyvAgMBAAGjYzBhMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
# BTADAQH/MB0GA1UdDgQWBBSubAWjkxPioufi1xzWx/B/yGdToDAfBgNVHSMEGDAW
# gBSubAWjkxPioufi1xzWx/B/yGdToDANBgkqhkiG9w0BAQwFAAOCAgEAgyXt6NH9
# lVLNnsAEoJFp5lzQhN7craJP6Ed41mWYqVuoPId8AorRbrcWc+ZfwFSY1XS+wc3i
# EZGtIxg93eFyRJa0lV7Ae46ZeBZDE1ZXs6KzO7V33EByrKPrmzU+sQghoefEQzd5
# Mr6155wsTLxDKZmOMNOsIeDjHfrYBzN2VAAiKrlNIC5waNrlU/yDXNOd8v9EDERm
# 8tLjvUYAGm0CuiVdjaExUd1URhxN25mW7xocBFymFe944Hn+Xds+qkxV/ZoVqW/h
# pvvfcDDpw+5CRu3CkwWJ+n1jez/QcYF8AOiYrg54NMMl+68KnyBr3TsTjxKM4kEa
# SHpzoHdpx7Zcf4LIHv5YGygrqGytXm3ABdJ7t+uA/iU3/gKbaKxCXcPu9czc8FB1
# 0jZpnOZ7BN9uBmm23goJSFmH63sUYHpkqmlD75HHTOwY3WzvUy2MmeFe8nI+z1TI
# vWfspA9MRf/TuTAjB0yPEL+GltmZWrSZVxykzLsViVO6LAUP5MSeGbEYNNVMnbrt
# 9x+vJJUEeKgDu+6B5dpffItKoZB0JaezPkvILFa9x8jvOOJckvB595yEunQtYQEg
# fn7R8k8HWV+LLUNS60YMlOH1Zkd5d9VUWx+tJDfLRVpOoERIyNiwmcUVhAn21klJ
# wGW45hpxbqCo8YLoRT5s1gLXCmeDBVrJpBAxggNJMIIDRQIBATBvMFsxCzAJBgNV
# BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9i
# YWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTM4NCAtIEc0AhABAzLhZb+beEPg
# mXWUY3cLMAsGCWCGSAFlAwQCAaCCAS0wGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJ
# EAEEMCsGCSqGSIb3DQEJNDEeMBwwCwYJYIZIAWUDBAIBoQ0GCSqGSIb3DQEBCwUA
# MC8GCSqGSIb3DQEJBDEiBCCHS+qjBLZ57qSEVWp6Nih8xmZUlluQ2qvHf2mHelm4
# pTCBsAYLKoZIhvcNAQkQAi8xgaAwgZ0wgZowgZcEIJGSR5tiNbl2Jr+2AW14CJGD
# cgPYc5HAbBuOPXf/4sc3MHMwX6RdMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBH
# bG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGlu
# ZyBDQSAtIFNIQTM4NCAtIEc0AhABAzLhZb+beEPgmXWUY3cLMA0GCSqGSIb3DQEB
# CwUABIIBgDDikHflQpe1xnfo5ua3z/ExkbIEVnk0oY4oNmb5jr/LOKI94N4TA2Pa
# DCoDa6hTjoB+clz3FxJ20tG2+kq64G/IJhsHuxBfrXDIFkXZuCN0q/JLb1827H59
# s/Lv8VO9XwbD3IVXrR2JiIeKEy6WQJgqZpoLSJubEFREkZmNUMn3lt1ctFoo+Qoz
# 3jk2404onuMDnNHjnVnGDQIWOMVALPFwe/0Eple9LLSjueU3PLP6p0X48cMFa2fx
# JZ0KSi2RruKn7fC/PDGnzmlmDk3iDvgPvjU4/AD6/aI7IkRBPmQMAIgMp2XUHKUO
# sbOlmYBdAXFjQB88XlW8ZjCifdMAtoQlBDzlMmKGOQp9SkADmbnrkON+TDQ0fMk+
# FEuoNtf4Jy9Wb7Xgwesnl1B8sFgQq5iKUty7vX6UxlwIw4v4hcurRr0S7JSI51Em
# 2z9C//MViP0igkjTjPleQOlDLbJ6KVkyGG6/QklxYr56s5LhlblyOrgxm3ifnGEx
# 6O5suxQC8A==
# SIG # End signature block
