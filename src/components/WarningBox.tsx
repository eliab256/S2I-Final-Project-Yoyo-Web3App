interface WarningBoxProps {
    title: string;
    message: string;
    txHash: string;
    onClose?: () => void;
}

const WarningBox: React.FC<WarningBoxProps> = ({ title, message, txHash, onClose }) => {
    return <></>;
};
export default WarningBox;
